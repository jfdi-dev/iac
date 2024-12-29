
output "value" {
  value = local.values

  precondition {
    condition     = local.values.artifact != null
    error_message = "Manifest file required `artifact` property"
  }
}
