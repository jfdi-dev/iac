
data aws_organizations_organization org {}

locals {
  accounts = data.aws_organizations_organization.org.non_master_accounts
  accounts_by_name = tomap({
    for account in local.accounts:
    account.name => account
  })

  security_account = contains(keys(local.accounts_by_name), "security") ? local.accounts_by_name["security"] : local.accounts_by_name["${var.project}-svc-security"]

  networking_account = contains(keys(local.accounts_by_name), "networking") ? local.accounts_by_name["networking"] : local.accounts_by_name["${var.project}-svc-networking"]

  tooling_account = contains(keys(local.accounts_by_name), "tooling") ? local.accounts_by_name["tooling"] : local.accounts_by_name["${var.project}-svc-tooling"]

  dev_account = contains(keys(local.accounts_by_name), "development") ? local.accounts_by_name["development"] : local.accounts_by_name["${var.project}-ops-development"]

  test_account = contains(keys(local.accounts_by_name), "testing") ? local.accounts_by_name["staging"] : local.accounts_by_name["${var.project}-ops-staging"]

  prod_account = contains(keys(local.accounts_by_name), "production") ? local.accounts_by_name["testing"] : local.accounts_by_name["${var.project}-ops-production"]
}
