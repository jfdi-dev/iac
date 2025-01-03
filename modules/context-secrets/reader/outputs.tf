
output "context_secrets" {
  value = {
    for key, secret in data.aws_secretsmanager_secret_version.context_secrets :
    key => secret.secret_string
  }
  sensitive = true
}