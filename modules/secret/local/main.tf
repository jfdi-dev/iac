
#
# `Secret - Local`
# ================
#
# A single, string secret (which is encrypted) and policies for reading and writing the value of the secret.
#

resource "aws_secretsmanager_secret" "secret" {
  name = var.name
}

resource "aws_secretsmanager_secret_version" "secret" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = var.value
}

data "aws_iam_policy_document" "read_secret" {
  statement {
    effect    = "Allow"
    resources = [aws_secretsmanager_secret.secret.arn]
    actions   = ["secretsmanager:GetSecretValue"]
  }
}

data "aws_iam_policy_document" "write_secret" {
  statement {
    effect    = "Allow"
    resources = [aws_secretsmanager_secret.secret.arn]
    actions   = ["secretsmanager:PutSecretValue"]
  }
}

resource "aws_iam_policy" "read_secret" {
  name   = "read-secret-${var.name}"
  policy = data.aws_iam_policy_document.read_secret.json
}

resource "aws_iam_policy" "write_secret" {
  name   = "write-secret-${var.name}"
  policy = data.aws_iam_policy_document.write_secret.json
}