provider aws {

}

provider aws {
  alias = north-virginia
  region = "us-east-1"
}


module manifest {
  source = "../artifact-manifest"
}

module "dr" {
  source = "../disaster-recovery"

  level = module.manifest.disaster_recovery_level
}

module project-context {
  source = "../project-context/reader"
}

locals {
  fqdn = "${module.manifest.artifact}.${module.project-context.env}.${module.project-context.tldp1}"
}

module static {
  source = "../static-content"

  name = module.manifest.artifact
  dr = module.dr
}

module cdn {
  providers = {
    aws.tls = aws.north-virginia
    aws.edge = aws.north-virginia
  }
  source = "../cdn"

  fqdn = local.fqdn
  
  static = [
    {
      fqdn = module.static.fqdn
    }
  ]
}

module dns {
  source = "../dns"

  fqdn = local.fqdn
  alias_to = module.cdn
}
