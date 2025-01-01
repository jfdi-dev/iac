provider "aws" {

}

module "project-context" {
  source = "../project-context"
}

module "artifact-manifest" {
  source = "../artifact-manifest"
}

module "deployer-role" {
  source = "../deployer-role"

  project         = module.project-context.value.project
  artifact_name   = module.artifact-manifest.artifact
  tooling_account = module.project-context.value.accounts.tooling

  policies = module.artifact-manifest.deployment.policies
}
