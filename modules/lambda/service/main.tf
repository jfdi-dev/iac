
#
# Lambda / Service
# ================
#
# Configures a suite of lambdas aligned to a singular 'service'.
#
# Uses input variables and filesystem conventions for ambient config.
#

locals {
  archive_path = "./.dist/${var.name}.zip"
}

data "archive_file" "lambda" {
  type = "zip"
  source_dir = var.src
  output_path = "./${var.name}.zip"

  lifecycle {
    precondition {
      condition = provider::local::direxists(var.src)
      error_message = "The `src` directory ('${var.src}') does not exist"
    }

    postcondition {
      condition = fileexists(self.output_path)
      error_message = "The service archive file ('${self.output_path}') was not created"
    }
  }
}

module "lambda_function" {
  for_each = toset(var.functions)
  
  source = "../function"

  name = "${var.name}-${each.key}"
  src = var.src
  handler = "handlers/${each.key}/index.handler"
  apigw_lambda = true

  # settings = fileexists("${var.src}handlers/${each.key}/manifest.yml") ? yamldecode(file("${var.src}handlers/${each.key}/manifest.yml")) : {
  #   runtime = var.
  # }
}

# resource "aws_lambda_function" "handlers" {
#   for_each = toset(var.functions)

#   lifecycle {
#     precondition {
#       condition = fileexists("${var.src}handlers/${each.key}/index.js")
#       error_message = "The lambda handler ('${var.src}handlers/${each.key}/index.js') does not exist"
#     }
#   }

#   filename = "./${var.name}.zip"
#   function_name = "${var.name}-${each.key}"
#   role = aws_iam_role.handler_role.arn
#   handler = "handlers/${each.key}"

#   runtime = fileexists("${var.src}handlers/${each.key}/manifest.yml") ? yamldecode(file("${var.src}handlers/${each.key}/manifest.yml")).runtime : "nodejs20.x"
# }

# data "aws_iam_policy_document" "handler_assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["lambda.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

# # todo: multi-roles / polp
# resource "aws_iam_role" "handler_role" {
#   name               = "myrole"
#   assume_role_policy = data.aws_iam_policy_document.handler_assume_role.json
# }

# resource "aws_api_gateway_integration" "integrations" {
#   for_each = {
#     for operation in local.operations: operation.op.operationId => operation
#   }
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   type = "AWS_PROXY"
#   resource_id = data.aws_api_gateway_resource.resources[each.value.path].id
#   http_method = upper(each.value.method)
#   integration_http_method = upper(each.value.method)
#   uri = aws_lambda_function.handlers[each.key].invoke_arn
# }

# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["apigateway.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

# data "aws_iam_policy_document" "lambda_policy" {
#   statement {
#     effect    = "Allow"
#     actions   = ["lambda:InvokeFunction"]
#     resources = [ for f in aws_lambda_function.handlers: f.arn ]
#   }
# }

# resource "aws_iam_policy" "lambda_policy" {
#   name = "${var.name}-policy"
#   policy = data.aws_iam_policy_document.lambda_policy.json
# }

# resource "aws_iam_role" "lambda_role" {
#   name = "${var.name}-role"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

# resource "aws_iam_role_policy_attachment" "role_policy" {
#   role = aws_iam_role.lambda_role.name
#   policy_arn = aws_iam_policy.lambda_policy.arn
# }
