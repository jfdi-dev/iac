
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