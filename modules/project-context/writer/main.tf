
data aws_organizations_organization org {}

data aws_caller_identity current {}

locals {
  accounts = { 
    for account in data.aws_organizations_organization.org.non_master_accounts:
    account.name => account.id
    if account.id != data.aws_caller_identity.current.account_id
    # Must omit current account as cannot create a share to account which owns ssm parameter
  }
}

resource aws_ssm_parameter project_context {
  tier = "Advanced"
  name = "project_context"
  type = "String"
  value = jsonencode({
    project = var.project
    accounts = {
      tooling = var.tooling_account
      security = var.security_account
      networking = var.networking_account
      dev = var.dev_account
      test = var.test_account
      prod = var.prod_account
    }
    regions = var.regions
    tldp1 = var.tldp1
  })
}

resource aws_ram_resource_share project_context {
  name = "project_context"
  allow_external_principals = false
}

resource aws_ram_resource_association project_context {
  resource_arn = aws_ssm_parameter.project_context.arn
  resource_share_arn = aws_ram_resource_share.project_context.arn
}

resource aws_ram_principal_association project_context {
  for_each = local.accounts

  resource_share_arn = aws_ram_resource_share.project_context.arn
  principal = each.value
}