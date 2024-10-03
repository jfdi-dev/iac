
locals {
  defaults = {
    
  }
  manifest = yamldecode(file(var.manifest_path))
  values = merge(local.defaults, local.manifest)
}