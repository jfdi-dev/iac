
output value {
  value = local.manifest

  precondition {
    condition = local.manifest.artifact != null
    error_message = "Manifest file required `artifact` property"
  }
}