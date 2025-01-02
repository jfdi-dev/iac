
module "project-context" {
  source = "../"
}

module "parameter" {
  source = "../../parameter/reader"

  name = module.project-context.parameter_name

  local = var.is_tooling
}

data "aws_caller_identity" "current" {}

locals {
  project_context = jsondecode(module.parameter.value[module.project-context.parameter_name])
  matching_envs = [
    for env, id in local.project_context.accounts :
    env
    if id == data.aws_caller_identity.current.account_id
  ]
  env = length(local.matching_envs) > 0 ? local.matching_envs[0] : null
}