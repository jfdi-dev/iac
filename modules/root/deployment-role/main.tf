terraform {
  backend s3 {
  }
}


provider aws {
  assume_role {
    role_arn = var.role
  }
}

module project-context {
  source = "../../project-context/reader"
}

module manifest {
  source = "../../artifact-manifest"
}

locals {
  policies = merge(module.manifest.value.deployment.policies, {
    named: "read-context-secret-${module.manifest.value.secrets}"
  })
}

module deployer-role {
  source = "../../deployer-role"

  project = module.project-context.value.project
  tooling_account = module.project-context.value.accounts.tooling

  artifact_name = module.manifest.value.artifact
  policies = local.policies
}