
resource "local_file" "secret_name" {
  content = jsonencode(var.secret)
  filename = "${path.module}/src/.bundle/secret.json"
}

module "oidc_lambda" {
  source = "../../function"

  depends_on = [ local_file.secret_name ]
  
  edge_lambda = true
  src = "${path.module}/src/.bundle/"
  name = "oidc-lambda"
}