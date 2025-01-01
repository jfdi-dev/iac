mock_provider "aws" {
  alias = "accounts_not_found"

  mock_data "aws_organizations_organization" {
    defaults = {
      non_master_accounts = [
        
      ]
    }
  }  
}

run "errors_when_accounts_not_found" {
  command = plan

  providers = {
    aws = aws.accounts_not_found
  }

  expect_failures = [ 
    check.exactly_one_account_for_every_marker,
    output.tooling,
    output.networking,
    output.security,
    output.development,
    output.staging,
    output.production
  ]
}
