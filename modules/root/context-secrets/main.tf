terraform {
  backend "s3" {
  }
}


provider "aws" {
  assume_role {
    role_arn = var.role
  }
}

module "manifest" {
  source = "../../artifact-manifest"
}

module "context-secrets" {
  source = "../../context-secrets/reader"

  context_secrets = module.manifest.secrets
}