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

provider "auth0" {

}

module "manifest" {
  source = "../../artifact-manifest"

  manifest_path = var.manifest_path
}

module "project-context" {
  source = "../../project-context/reader"
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

locals {
  config = merge(module.project-context.value, module.manifest.object)
  fqdn   = "${local.config.artifact}.${module.project-context.env}.${local.config.tldp1}"
  statics = {
    for key, value in local.config.service.statics :
    "${key}.${local.fqdn}" => merge(value, { short_name : key })
  }
}

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

  auth = local.config.auth

  statics   = local.statics
  apis      = local.config.service.apis
  streaming = try(local.config.service.streaming, {})
  #datastores = local.config.service.datastores
}