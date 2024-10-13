
module "jwt-lambda" {
  source = "../../function"

  src = "${path.module}/src/.bundle/"
  name = "jwt-lambda"
  apigw_lambda = true 
}