
locals {
  context_secrets_file = "${path.root}/${var.file}"
  context              = fileexists(local.context_secrets_file) ? yamldecode(file(local.context_secrets_file)) : {}
}

resource "aws_secretsmanager_secret" "context_secret" {
  for_each = local.context
  name     = "context-secret-${each.key}"
}

resource "aws_secretsmanager_secret_version" "context_secret" {
  for_each      = local.context
  secret_id     = aws_secretsmanager_secret.context_secret[each.key].id
  secret_string = jsonencode(each.value)
}

data "aws_iam_policy_document" "context_secret_policies" {
  for_each = local.context
  statement {
    effect    = "Allow"
    resources = [aws_secretsmanager_secret_version.context_secret[each.key].arn]
    actions   = ["secretsmanager:GetSecretValue"]
  }
}

resource "aws_iam_policy" "context_secret_policies" {
  for_each = local.context
  name     = "read-context-secret-${each.key}"
  policy   = data.aws_iam_policy_document.context_secret_policies[each.key].json
}