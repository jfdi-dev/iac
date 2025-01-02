
data "aws_organizations_organization" "org" {}

data "aws_caller_identity" "current" {}

module "project-context" {
  source = "../"
}

locals {
  accounts = {
    for account in data.aws_organizations_organization.org.non_master_accounts :
    account.name => account.id
    if account.id != data.aws_caller_identity.current.account_id
    # Must omit current account as cannot create a share to account which owns ssm parameter
  }

  value = {
    project = var.project
    accounts = {
      tooling    = var.tooling_account
      security   = var.security_account
      networking = var.networking_account
      dev        = var.dev_account
      test       = var.test_account
      prod       = var.prod_account
    }
    regions   = var.regions
    tldp1     = var.tldp1
    terraform = var.terraform
  }
}

module "parameter" {
  source = "../../parameter/writer"

  name = module.project-context.parameter_name
  value = jsonencode(local.value)

  shared_with = values(local.accounts)
}
