
output "url" {
  value       = aws_lambda_function_url.url.function_url
  description = "Public URL for the lambda function"
}

output "function" {
  value = module.lambda.function
}

output "function_arn" {
  value = module.lambda.function.arn
}