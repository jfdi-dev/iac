
output "function" {
  value = aws_lambda_function.lambda
}

output "settings" {
  value = module.manifest.settings
}