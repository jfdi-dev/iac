
output "function" {
  value = aws_lambda_function.lambda
}

output "settings" {
  value = module.manifest.settings
}

output "role" {
  value = aws_iam_role.lambda_role.arn
}