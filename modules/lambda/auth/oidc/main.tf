
resource "local_file" "secret_name" {
  content  = var.secret
  filename = "${path.module}/src/.bundle/secret"
}

resource "random_string" "edge_lambda" {
  length  = 8
  special = false
  numeric = false
  upper   = true
  lower   = false
}

module "oidc_lambda" {
  source = "../../function"

  depends_on = [local_file.secret_name]

  edge_lambda = true
  src         = "${path.module}/src/.bundle/"
  name        = "oidc-lambda-${random_string.edge_lambda.result}"
}