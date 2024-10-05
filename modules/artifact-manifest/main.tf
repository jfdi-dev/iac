
locals {
  defaults = {
    deployment = {
      policies = {
        custom = {}
        named = []
        managed = []
      }
    }
  }
  manifest = yamldecode(file(var.manifest_path))
  values = merge(local.defaults, local.manifest)
}