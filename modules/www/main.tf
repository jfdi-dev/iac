terraform {
  backend s3 {
  }
}

# provider aws {
#   alias = "north-virginia"
#   region = "us-east-1"
# }

module manifest {
  source = "../artifact-manifest"

  manifest_path = var.manifest_path
}

module project-context {
  source = "../project-context/reader"
}

locals {
  config = merge(module.project-context.value, module.manifest.value)
  fqdn = "${local.config.artifact}.${module.project-context.env}.${local.config.tldp1}"
}

module dr-from-env {
  source = "../dr-from-env"

  env = module.project-context.env
}

module "dr" {
  source = "../disaster-recovery"

  level = module.dr-from-env.level
}

module static {
  source = "../static-content"

  name = local.fqdn
  dr = module.dr
}

module cdn {
  depends_on = [ module.static ]

  providers = {
    aws.tls = aws.north-virginia
    aws.edge = aws.north-virginia
  }
  source = "../cdn"

  protected = false
  fqdn = local.fqdn
  
  static = [
    {
      fqdn = module.static.fqdn
    }
  ]
}

module dns {
  depends_on = [ 
    module.cdn
   ]

  source = "../dns"

  fqdn = local.fqdn
  alias_to = module.cdn
}
