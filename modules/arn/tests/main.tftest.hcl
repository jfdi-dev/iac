mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "012345678901"
    }
  }

  mock_data "aws_region"   {
    defaults = {
      id = "eu-west-2"
    }
  }
}

variables {
  service = "iam"
}

run "service_is_required" {
  command = plan

  variables {
    service = ""
  }

  expect_failures = [ 
    var.service
  ]
}

run "service_only_will_find_account_and_region" {
  command = plan

  variables {
    
  }

  assert {
    condition = "arn:aws:iam:eu-west-2:012345678901:*" == output.value
    error_message = "Arn value did not match expectations"
  }
}

run "overriding_account_and_region_will_use_empty_values" {
  command = plan

  variables {
    region = ""
    account = ""
  }

  assert {
    condition = "arn:aws:iam:::*" == output.value
    error_message = "Arn value did not match expectations"
  }
}

run "overriding_resource_type_will_include_resource_id" {
  command = plan

  variables {
    resource_type = "roles"
    resource_id = "my_role"
  }

   assert {
    condition = "arn:aws:iam:eu-west-2:012345678901:roles/my_role" == output.value
    error_message = "Arn value did not match expectations"
  }
}