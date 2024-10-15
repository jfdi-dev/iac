
output context_secrets {
  value = jsonencode({
    for key, secret in data.aws_secretsmanager_secret_version.context_secrets:
      key => jsondecode(secret.secret_string)
  })
  sensitive = true
}