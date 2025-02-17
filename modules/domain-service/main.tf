
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

module "datastore" {
  source = "../datastore"

  relational = var.datastores.relational
  document   = var.datastores.document
}

module "apis" {
  source = "../api/rest"

  for_each = var.apis

  env          = var.env
  name         = each.key
  openapi_spec = each.value.spec
  basepath     = "${path.root}/${each.value.src}"
}

module "statics" {
  source = "../static-content"

  for_each = var.statics

  name = each.key
}

module "streaming_functions" {
  source = "../lambda/streaming"

  for_each = var.streaming

  name = each.key
  src  = "${path.root}/${each.value.src}"
}

locals {
  apis = {
    for key, value in var.apis :
    key => merge(
      value,
      module.apis[key],
      { name : key }
    )
  }
  statics = {
    for key, value in var.statics :
    key => merge(
      value,
      module.statics[key],
      { name : key }
    )
  }
  streaming = {
    for key, value in var.streaming :
    key => merge(
      value,
      module.streaming_functions[key],
      { name : key }
    )
  }
}

module "auth" {
  count  = var.protected ? 1 : 0
  source = "../auth"

  fqdn = var.fqdn

  connections    = var.auth.connections
  disable_signup = var.auth.disable_signup

  # Limited to first api + first static, for now
  api    = local.apis[keys(local.apis)[0]]
  client = local.statics[keys(local.statics)[0]]
}

module "oidc_lambda" {
  count  = var.protected ? 1 : 0
  source = "../lambda/auth/oidc"

  providers = {
    aws = aws.edge
  }

  secret = module.auth[0].secret_name
}


module "cdn" {
  providers = {
    aws.tls = aws.tls
  }
  source = "../cdn"

  fqdn             = var.fqdn
  auth_lambda_arns = var.protected ? [module.oidc_lambda[0].function.qualified_arn] : toset([])

  api = local.apis
  # [ 
  #   for name, api in var.apis: 
  #     {
  #       fqdn = module.apis[name].fqdn
  #       path = api.path
  #     } 
  # ]
  static = local.statics
  # [ 
  #   for name, static in var.statics: 
  #     {
  #       # just pass in the module???
  #       fqdn = module.statics[name].fqdn
  #       bucket_name = module.statics[name].bucket_name
  #       path = static.path
  #     }
  # ]
  streaming = local.streaming
}

module "dns" {
  source = "../dns/alias"

  fqdn     = var.fqdn
  alias_to = module.cdn
}
