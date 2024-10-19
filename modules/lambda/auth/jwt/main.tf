
resource local_file scopes_map {
  content = jsonencode(var.scopes-map)
  filename = "${path.module}/src/.bundle/scopes.json"
}

module "jwt-lambda" { 
  source = "../../function"

  depends_on = [ local_file.scopes_map ]

  src = "${path.module}/src/.bundle/"
  name = "jwt-lambda"
  apigw_lambda = true 
}