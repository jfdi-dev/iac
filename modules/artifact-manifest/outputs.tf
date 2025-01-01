
output "object" {
  value = local.object

  precondition {
    condition     = local.object != null
    error_message = "Manifest object is null"
  }
}

output "artifact" {
  value = local.object.artifact

  precondition {
    condition     = contains(keys(local.object), "artifact")
    error_message = "Manifest file required `artifact` property"
  }
}

output "deployment" {
  value = local.object.deployment
}

output "secrets" {
  value = local.object.secrets
}