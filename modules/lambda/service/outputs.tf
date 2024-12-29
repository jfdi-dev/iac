
output "handlers" {
  value = { for idx, f in module.lambda_function : idx => f.function }
}
