
module "manifest" {
  source = "../manifest"

  path = "${var.src}${var.handler}"
}

locals {
  zip_path = "./.dist/${var.name}.zip"
  principal_identifiers = concat(
    ["lambda.amazonaws.com"],
    var.edge_lambda ? ["edgelambda.amazonaws.com"] :
    var.apigw_lambda ? ["apigateway.amazonaws.com"] : []
  )

  default_service_policies = ["AWSLambdaBasicExecutionRole"]

  context_policies   = [for c in try(module.manifest.settings.integrations.contexts, []) : "read-secret-context-secret-${c}"]
  datastore_policies = [for d in try(module.manifest.settings.integrations.datastores, []) : "access-datastore-${d}"]

  policies = {
    custom  = coalesce(module.manifest.settings.policies.custom, {})
    named   = concat(coalesce(tolist(module.manifest.settings.policies.named), []), local.context_policies, local.datastore_policies)
    managed = coalesce(module.manifest.settings.policies.managed, [])
    service = coalesce(concat(tolist(module.manifest.settings.policies.service), local.default_service_policies), [])
  }
}

module "role_policies" {
  source = "../../role-policies"

  role = aws_iam_role.lambda_role.name

  policies = local.policies
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = local.principal_identifiers
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = var.src
  output_path = local.zip_path
}

resource "aws_lambda_function" "lambda" {

  depends_on = [data.archive_file.lambda]

  # lifecycle {
  #   # precondition {
  #   #   condition = fileexists(local.zip_path)
  #   #   error_message = "The lambda archive file ('${local.zip_path}') must already exist"
  #   # }

  #   # Really do need this, but can't without some `handler` fettling
  #   # precondition {
  #   #   condition = fileexists("${var.src}${var.handler}")
  #   #   error_message = "The lambda handler ('${var.src}${var.handler}') does not exist"
  #   # }
  # }

  function_name = var.name
  role          = aws_iam_role.lambda_role.arn
  filename      = local.zip_path
  handler       = var.handler
  publish       = true

  # environment {
  #   variables = module.manifest.settings.environment
  # }

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime     = module.manifest.settings.runtime.name
  memory_size = module.manifest.settings.runtime.memory_size
  timeout     = module.manifest.settings.runtime.timeout

  reserved_concurrent_executions = module.manifest.settings.concurrency.reserved
}

resource "aws_lambda_provisioned_concurrency_config" "provisioning" {
  count = module.manifest.settings.concurrency.provisioned > 0 ? 1 : 0

  function_name = aws_lambda_function.lambda.arn
  qualifier     = aws_lambda_function.lambda.version

  provisioned_concurrent_executions = module.manifest.settings.concurrency.provisioned
}