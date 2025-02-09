
module "lambda" {
  source = "../function"

  name = var.name
  src  = var.src
}

resource "aws_lambda_function_url" "url" {
  function_name = module.lambda.function.function_name
  # Should be IAM
  authorization_type = "NONE"
  invoke_mode        = "RESPONSE_STREAM"
}
