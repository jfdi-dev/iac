terraform {
  backend s3 {

  }
}

provider aws {
  assume_role {
    role_arn = var.role
  }
}

provider aws {
  alias = "north-virginia"
  region = "us-east-1"
  assume_role {
    role_arn = var.role
  }
}

module manifest {
  source = "../../artifact-manifest"

  manifest_path = var.manifest_path
}

module project-context {
  source = "../../project-context/reader"
}

locals {
  config = merge(module.project-context.value, module.manifest.value)
  fqdn = "${local.config.artifact}.${module.project-context.env}.${local.config.tldp1}"
}

module dr-from-env {
  source = "../../dr-from-env"

  env = module.project-context.env
}

module dr { 
  source = "../../disaster-recovery"

  level = module.dr-from-env.level
}

# ^ Very boilerplate; Much wet

module domain-service {
  source = "../../domain-service"

  providers = {
    default = aws
    aws.tls = aws.north-virginia
    aws.edge = aws.north-virginia
  }

  fqdn = local.fqdn
  protected = true

  disaster_recovery_level = module.dr.level

  statics = local.config.service.statics
  apis = local.config.service.apis
  datastores = local.config.service.datastores
}