
#
# Domain Service
# ==============
#
# Composite comprising:
#
# - single-page-application (0..*)
# - application-programming-interface (1..*)
# - datastore (0..*)
#

module "dr" {
  source = "../disaster-recovery"

  level = var.disaster_recovery_level
}

# module "datastore" {
#   source = "../datastore"

#   for_each = var.datastores

#   rdbms = {
#     y = 1
#   }

#   document = {
#     x = 1
#   }  
# }

module "apis" {
  source = "../api/rest"

  for_each = var.apis

  name = each.key
  openapi_spec = each.value.spec
  basepath = each.value.src
}

module "statics" {
  source = "../static-content"

  for_each = var.statics

  name = each.key
  dr = module.dr
}

module "cdn" {
  providers = {
    aws.tls = aws.tls
    aws.edge = aws.edge
  }
  source = "../cdn"

  fqdn = var.fqdn
  protected = true

  api = [ 
    for name, api in var.apis: 
      {
        fqdn = module.apis[name].fqdn
        path = api.path
      } 
  ]
  static = [ 
    for name, static in var.statics: 
      {
        fqdn = module.statics[name].fqdn
        path = static.path
      }
  ]
}

module "dns" {
  source = "../dns"

  fqdn = var.fqdn
  alias_to = module.cdn
}
