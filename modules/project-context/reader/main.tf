
module project-context {
  source = "../"
}

data aws_ram_resource_share project_context {
  name = module.project-context.parameter_name
  resource_owner = var.is_tooling ? "SELF" : "OTHER-ACCOUNTS" 
}

data aws_ssm_parameter project_context {
  name = data.aws_ram_resource_share.project_context.resource_arns[0]
}

data aws_caller_identity current {}

locals {
  project_context = jsondecode(data.aws_ssm_parameter.project_context.insecure_value)
  matching_envs = [
    for env, id in local.project_context.accounts:
      env
    if id == data.aws_caller_identity.current.account_id
  ]
  env = length(local.matching_envs) > 0 ? local.matching_envs[0] : null
}