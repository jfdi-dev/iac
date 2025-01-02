mock_provider "aws" {
  
}

run "writes_project_context_to_param" {
  command = plan

  variables {
    project = "test"
    tldp1   = "test.com"

    regions = {
      primary   = "eu-west-2"
      secondary = "eu-west-1"
    }

    terraform = {
      state = "s3.state"
      locks = "locks.s3.state"
    }

    tooling_account    = "1"
    networking_account = "2"
    security_account   = "3"
    dev_account        = "4"
    test_account       = "5"
    prod_account       = "6"
  }

  assert {
    condition = jsonencode(nonsensitive(output.value)) == jsonencode({
      accounts = {
        dev        = "4"
        networking = "2"
        prod       = "6"
        security   = "3"
        test       = "5"
        tooling    = "1"        
      }
      regions = {
        primary = "eu-west-2"
        secondary = "eu-west-1"
      }
      terraform = {
        locks = "locks.s3.state"
        state = "s3.state"
      }
      project = "test"
      tldp1 = "test.com"
    })
    error_message = "Output did not match expectation (${jsonencode(nonsensitive(output.value))})"
  }
}