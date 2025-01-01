
#
# `Account Lookup`
# ================
# 
# Outputs all well-known accounts, eg: security, networking, tooling, etc.
#
# Requires permission to read the AWS Organization's Non-master Accounts, which is provided by the `Org` module, deployed manually as part of Foundations.
#
# Will look for accounts that contain markers in their name, eg: 'security' / 'tooling' / 'networking' / etc.
#

data "aws_organizations_organization" "org" {

}

locals {
  non_master_accounts = data.aws_organizations_organization.org.non_master_accounts
  
  # This should come from `org`?
  account_markers = [
    "security",
    "networking",
    "tooling",
    "development",
    "staging",
    "production"
  ]

  marker_accounts = {
    for marker in local.account_markers:
    marker => [ 
      for nma in local.non_master_accounts: 
      nma 
      if strcontains(nma.name, marker) 
    ]
  }

  accounts = {
    for marker, accounts in local.marker_accounts:
    marker => length(accounts) <= 1 ? one(accounts) : null
  }
}

check "exactly_one_account_for_every_marker" {
  assert {
    condition = alltrue([ for marker, accounts in local.accounts: contains(local.account_markers, marker) && accounts != null ])
    error_message = "'Account not found' or 'too many accounts found' for marker"
  }
}