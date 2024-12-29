
output "fqdn" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}

output "paths" {
  value = [for integration in data.aws_api_gateway_resource.resources : integration.path]
}

output "handlers" {
  value = [for handler in module.lambda_service.handlers : handler.function_name]
}

output "functions" {
  value = [for function in module.lambda_service.handlers : function]
}

output "actions" {
  value = [
    for op in local.operations :
    "${op.method} ${op.path}"
  ]
}