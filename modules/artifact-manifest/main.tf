
# 
# `Artifact Manifest`
# ===================
#
# Acts as a 'view' on a `Manifest`. Will further parse the object into expected values, specify defaults, etc.
#

module "manifest" {
  source = "../manifest"

  path = var.manifest_path
}

locals {
  defaults = {
    deployment = {
      policies = {
        custom  = {}
        named   = []
        managed = []
        service = []
      }
    }
    secrets = []
  }
  object = merge(local.defaults, module.manifest.object)
}