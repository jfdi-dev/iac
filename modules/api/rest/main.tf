
# resource "aws_api_gateway_authorizer" "auth" {
#   name = "${var.name}-authorizer"
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   authorizer_uri = aws_lambda_function.authorizer.invoke_arn
#   authorizer_credentials = aws_iam_role.lambda_role.arn
# }

locals {
  openapi_spec = yamldecode(file("${var.basepath}${var.openapi_spec}"))
  operations = flatten([
    for path, methods in local.openapi_spec.paths: 
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

  body = jsonencode(local.openapi_spec)

  endpoint_configuration {
    types = [ "REGIONAL" ]
  }
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
  integration_http_method = upper(each.value.method)
  uri = module.lambda_service.handlers[each.key].invoke_arn
}

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
  stage_name = "$default"
}

