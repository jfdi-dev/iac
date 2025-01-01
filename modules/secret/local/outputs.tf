
output "_type" {
  value       = "aws"
  description = "The type of secret"
}

output "secret" {
  value       = aws_secretsmanager_secret.secret
  description = "The secret resource"
}

output "secret_version_arn" {
  value       = aws_secretsmanager_secret_version.secret.arn
  description = "The secret version ARN"
}

output "secret_version_id" {
  value       = aws_secretsmanager_secret_version.secret.id
  description = "The secret version ID"
}

output "read_policy" {
  value       = aws_iam_policy.read_secret
  description = "The read secret policy resource"
}

output "write_policy" {
  value = aws_iam_policy.write_secret
  description = "The write secret policy resource"
}