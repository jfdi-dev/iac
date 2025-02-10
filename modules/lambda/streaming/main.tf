
module "lambda" {
  source = "../function"

  name    = var.name
  src     = var.src
  handler = "${var.name}/index.handler"
}

resource "aws_lambda_function_url" "url" {
  function_name = module.lambda.function.function_name
  # Should be IAM
  authorization_type = "AWS_IAM"
  invoke_mode        = "RESPONSE_STREAM"
}
