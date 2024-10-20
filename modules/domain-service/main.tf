
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

module auth {
  count = var.protected ? 1 : 0
  source = "../auth"

  fqdn = var.fqdn
  
  # Limited to first api + first static, for now
  api = var.apis[0]
  client = var.statics[0]
}

module "oidc_lambda" {
  count = var.protected ? 1 : 0
  source = "../lambda/auth/oidc"

  providers = {
    aws = aws.edge
  }

  secret = module.auth[0].secret_name
}

module "apis" {
  source = "../api/rest"

  for_each = var.apis

  env = var.env
  name = each.key
  openapi_spec = each.value.spec
  basepath = "${path.root}/${each.value.src}"
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
  }
  source = "../cdn"

  fqdn = var.fqdn
  auth_lambda_arns = module.oidc_lambda[*].function.qualified_arn

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
        # just pass in the module???
        fqdn = module.statics[name].fqdn
        bucket_name = module.statics[name].bucket_name
        path = static.path
      }
  ]
}

module "dns" {
  source = "../dns"

  fqdn = var.fqdn
  alias_to = module.cdn
}
