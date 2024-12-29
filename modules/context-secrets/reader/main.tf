
data "aws_secretsmanager_secret_version" "context_secrets" {
  for_each = {
    for context_secret in var.context_secrets :
    context_secret => context_secret
  }

  secret_id = "context-secret-${each.key}"
}