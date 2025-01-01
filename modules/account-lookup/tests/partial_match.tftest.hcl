mock_provider "aws" {
  alias = "partial_match"

  mock_data "aws_organizations_organization" {
    defaults = {
      non_master_accounts = [
        {
          arn = "arn1"
          email = "email1"
          id = "aaaaaa"
          name = "thing_tooling"
          status = "ok"
        },
        {
          arn = "arn2"
          email = "email2"
          id = "bbbbbb"
          name = "thing_security"
          status = "ok"
        },
        {
          arn = "arn3"
          email = "email3"
          id = "cccccc"
          name = "thing_networking"
          status = "ok"
        },
        {
          arn = "arn4"
          email = "email4"
          id = "dddddd"
          name = "thing_svc_development"
          status = "ok"
        },
        {
          arn = "arn5"
          email = "email5"
          id = "eeeeee"
          name = "thing_svc_staging"
          status = "ok"
        },
        {
          arn = "arn6"
          email = "email6"
          id = "ffffff"
          name = "thing_svc_production"
          status = "ok"
        }
      ]
    }
  }  
}

run "accounts_are_found_with_partial_match" {
  command = plan

  providers = {
    aws = aws.partial_match
  }

  assert {
    condition = provider::assert::not_empty(output.security_account)
    error_message = "Security Account was not found."
  }

  assert {
    condition = provider::assert::not_empty(output.tooling_account)
    error_message = "Tooling Account was not found."
  }

  assert {
    condition = provider::assert::not_empty(output.networking_account)
    error_message = "Networking Account was not found."
  }

  assert {
    condition = provider::assert::not_empty(output.development_account)
    error_message = "Development Account was not found."
  }

  assert {
    condition = provider::assert::not_empty(output.staging_account)
    error_message = "Staging Account was not found."
  }

  assert {
    condition = provider::assert::not_empty(output.production_account)
    error_message = "Production Account was not found."
  }
}
