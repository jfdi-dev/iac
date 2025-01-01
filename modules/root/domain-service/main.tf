terraform {
  backend "s3" {

  }
}

provider "aws" {
  assume_role {
    role_arn = var.role
  }
}

provider "aws" {
  alias  = "north-virginia"
  region = "us-east-1"
  assume_role {
    role_arn = var.role
  }
}

module "manifest" {
  source = "../../artifact-manifest"

  manifest_path = var.manifest_path
}

module "project-context" {
  source = "../../project-context/reader"
}

locals {
  config = merge(module.project-context.value, module.manifest.object)
  fqdn   = "${local.config.artifact}.${module.project-context.env}.${local.config.tldp1}"
}

module "dr-from-env" {
  source = "../../dr-from-env"

  env = module.project-context.env
}

module "dr" {
  source = "../../disaster-recovery"

  level = module.dr-from-env.level
}

# ^ Very boilerplate; Much wet

# provider auth0 {

# }

module "domain-service" {
  source = "../../domain-service"

  providers = {
    aws      = aws
    aws.tls  = aws.north-virginia
    aws.edge = aws.north-virginia
  }

  fqdn      = local.fqdn
  protected = true
  env       = module.project-context.env

  disaster_recovery_level = module.dr.level

  manifest = module.manifest

  statics = {
    for key, value in local.config.service.statics :
    "${key}.${local.fqdn}" => merge(value, { short_name : key })
  }
  apis = local.config.service.apis
  #datastores = local.config.service.datastores
}