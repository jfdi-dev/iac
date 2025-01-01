mock_provider "aws" {
  alias = "exact_match"

  mock_data "aws_organizations_organization" {
    defaults = {
      non_master_accounts = [
        {
          arn = "arn1"
          email = "email1"
          id = "aaaaaa"
          name = "tooling"
          status = "ok"
        },
        {
          arn = "arn2"
          email = "email2"
          id = "bbbbbb"
          name = "security"
          status = "ok"
        },
        {
          arn = "arn3"
          email = "email3"
          id = "cccccc"
          name = "networking"
          status = "ok"
        },
        {
          arn = "arn4"
          email = "email4"
          id = "dddddd"
          name = "development"
          status = "ok"
        },
        {
          arn = "arn5"
          email = "email5"
          id = "eeeeee"
          name = "staging"
          status = "ok"
        },
        {
          arn = "arn6"
          email = "email6"
          id = "ffffff"
          name = "production"
          status = "ok"
        }
      ]
    }
  }  
}

run "accounts_are_found_with_exact_match" {
  command = plan

  providers = {
    aws = aws.exact_match
  }

  assert {
    condition = provider::assert::not_null(output.security)
    error_message = "Security Account was not found."
  }

  assert {
    condition = provider::assert::not_null(output.tooling)
    error_message = "Tooling Account was not found."
  }

  assert {
    condition = provider::assert::not_null(output.networking)
    error_message = "Networking Account was not found."
  }

  assert {
    condition = provider::assert::not_null(output.development)
    error_message = "Development Account was not found."
  }

  assert {
    condition = provider::assert::not_null(output.staging)
    error_message = "Staging Account was not found."
  }

  assert {
    condition = provider::assert::not_null(output.production)
    error_message = "Production Account was not found."
  }
}
