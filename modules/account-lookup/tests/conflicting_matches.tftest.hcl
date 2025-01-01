mock_provider "aws" {
  alias = "conflicting_matches"

  mock_data "aws_organizations_organization" {
    defaults = {
      non_master_accounts = [
        {
          arn = "arn1a"
          email = "email1a"
          id = "aaaaaa-1"
          name = "tooling1"
          status = "ok"
        },
        {
          arn = "arn1b"
          email = "email1b"
          id = "aaaaaa-1"
          name = "tooling2"
          status = "ok"
        },
        {
          arn = "arn2a"
          email = "email2a"
          id = "bbbbbb-1"
          name = "security1"
          status = "ok"
        },
        {
          arn = "arn2b"
          email = "email2b"
          id = "bbbbbb-2"
          name = "security2"
          status = "ok"
        },
        {
          arn = "arn3a"
          email = "email3a"
          id = "cccccc-1"
          name = "networking1"
          status = "ok"
        },
        {
          arn = "arn3b"
          email = "email3b"
          id = "cccccc-2"
          name = "networking2"
          status = "ok"
        },
        {
          arn = "arn4a"
          email = "email4a"
          id = "dddddd-1"
          name = "development1"
          status = "ok"
        },
        {
          arn = "arn4b"
          email = "email4b"
          id = "dddddd-2"
          name = "development2"
          status = "ok"
        },
        {
          arn = "arn5a"
          email = "email5a"
          id = "eeeeee-1"
          name = "staging1"
          status = "ok"
        },
        {
          arn = "arn5b"
          email = "email5b"
          id = "eeeeee-2"
          name = "staging2"
          status = "ok"
        },
        {
          arn = "arn6a"
          email = "email6a"
          id = "ffffff-1"
          name = "production1"
          status = "ok"
        },
        {
          arn = "arn6b"
          email = "email6b"
          id = "ffffff-2"
          name = "production2"
          status = "ok"
        }
      ]
    }
  }  
}

run "errors_when_conflicting_accounts_are_found" {
  command = plan

  providers = {
    aws = aws.conflicting_matches
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
