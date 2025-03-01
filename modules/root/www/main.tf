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

module "static" {
  source = "../../static-content"

  name = local.fqdn
}

module "cdn" {
  depends_on = [module.static]

  providers = {
    aws.tls = aws.north-virginia
  }
  source = "../../cdn"

  # protected = false
  fqdn = local.fqdn

  static = { "${local.fqdn}" = module.static }
}

module "dns" {
  depends_on = [
    module.cdn
  ]

  source = "../../dns/alias"

  fqdn     = local.fqdn
  alias_to = module.cdn
}
