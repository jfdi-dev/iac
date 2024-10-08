provider aws {

}

module project-context {
  source = "github.com/jfdi-dev/iac/modules/project-context@main"
}

module artifact-manifest {
  source = "github.com/jfdi-dev/iac/modules/artifact-manifest@main"
}

module deployer-role {
  source = "../deployer-role"

  project = module.project-context.value.project
  artifact_name = module.artifact-manifest.value.artifact
  tooling_account = module.project-context.value.accounts.tooling

  policies = {
    custom = module.artifact-manifest.value.deployment.permissions
    named = module.artifact-manifest.value.deployment.name_policies
    managed = modue.artifact-manifest.value.deployment.managed_policies
  }
}
