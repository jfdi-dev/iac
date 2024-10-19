
locals {
  raw_spec = yamldecode(file("${var.basepath}${var.openapi_spec}"))
  openapi_spec = yamldecode(templatefile("${var.basepath}${var.openapi_spec}", {
    authorizer_uri = module.jwt-auth.function.invoke_arn
  }))
  # Horrific. AWS moans if you set scopes on a non-cognito authorizer. Whole thing needs binning.
  fixed_spec = merge(
    local.openapi_spec,
    {
      paths = { 
        for path, ops in local.openapi_spec.paths:
        path => { 
          for method, settings in ops:
          method => merge({
            for setting, values in settings:
            setting => values
            if setting != "security"
          }, {
            security = contains(keys(settings), "security") ? [
              for schemes in settings["security"]:
                {
                  # Finally, we empty out the scopes. fml.
                  for name, scopes in schemes:
                  name => []
                }
            ]: []
          })
        }
      }
    }
  )
  operations = flatten([
    for path, methods in local.raw_spec.paths: 
    [
      for method, op in methods:
      {
        path = path,
        method = method,
        op = op
      }
    ]
  ])
}

resource "aws_api_gateway_rest_api" "api" {
  name = var.name

  body = jsonencode(local.fixed_spec)

  endpoint_configuration {
    types = [ "REGIONAL" ]
  }
}

locals {
  scopes_map = {
    for item in local.operations:
    item.op.operationId => 
      contains(keys(item.op), "security") ?
        flatten([ 
          for scheme in item.op.security:
            [ for name, scopes in scheme: scopes ]
          ]
        )
      : []
  }
}

module jwt-auth {
  source = "../../lambda/auth/jwt"

  scopes-map = local.scopes_map
}

# resource "aws_api_gateway_authorizer" "auth" {
#   name = "${var.name}-authorizer"
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   authorizer_uri = module.jwt-auth.function.invoke_arn
#   authorizer_credentials = module.jwt-auth.role
#   type = "REQUEST"
# }

data "aws_api_gateway_authorizers" "authorizers" {
  rest_api_id = aws_api_gateway_rest_api.api.id
}

data "aws_api_gateway_resource" "resources" {
  for_each = local.openapi_spec.paths
  rest_api_id = aws_api_gateway_rest_api.api.id
  path = each.key
}

module "lambda_service" {
  source = "../../lambda/service"

  name = var.name
  src = var.basepath
  functions = toset(local.operations[*].op.operationId) 
}

resource "aws_api_gateway_integration" "integrations" {
  for_each = {
    for operation in local.operations: operation.op.operationId => operation
  }
  rest_api_id = aws_api_gateway_rest_api.api.id
  type = "AWS_PROXY"
  resource_id = data.aws_api_gateway_resource.resources[each.value.path].id
  http_method = upper(each.value.method)
  # Must always use post to downstream lambda?
  integration_http_method = "POST" #upper(each.value.method)
  uri = module.lambda_service.handlers[each.key].invoke_arn
  # Apparently, execution role is not needed...
  #credentials = module.lambda_service.handlers[each.key].role
}

# resource aws_api_gateway_method methods {
#   for_each = {
#     for operation in local.operations: operation.op.operationId => operation
#   }
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   resource_id = data.aws_api_gateway_resource.resources[each.value.path].id
#   http_method = upper(each.value.method)
#   authorization = "CUSTOM"
#   authorizer_id = aws_api_gateway_authorizer.auth.id
# }

# resource "aws_lambda_function" "authorizer" {

# }

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode(concat(
      [
        aws_api_gateway_rest_api.api.body
      ],
      [ 
        for integration in aws_api_gateway_integration.integrations: integration.id 
      ]
    )))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id = aws_api_gateway_rest_api.api.id

  # use env name ?
  stage_name = var.env
}


resource "aws_lambda_permission" "lambda_permission" {
  for_each = module.lambda_service.handlers

  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*"
}

resource "aws_lambda_permission" "authorizer_permission" {
  action = "lambda:InvokeFunction"
  function_name = module.jwt-auth.function.function_name
  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/authorizers/${data.aws_api_gateway_authorizers.authorizers.ids[0]}"
}
