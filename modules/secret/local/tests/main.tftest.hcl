mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{}"
    }
  }
}

variables {
  name = "my-secret"
  value = "1234567890"
}

run "name_cannot_be_empty" {
  command = plan

  variables {
    name = ""
  }

  expect_failures = [ 
    var.name
  ]
}

run "value_cannot_be_empty" {
  command = plan

  variables {
    value = ""
  }

  expect_failures = [ 
    var.value
  ]
}

run "secret_is_output" {
  command = plan

  assert {
    condition = output.secret != null
    error_message = "Output `secret` was null"
  }
}

run "secret_version_arn_is_output" {
  command = apply

  assert {
    condition = output.secret_version_arn != null
    error_message = "Output `secret_version_arn` was null"
  }
}

run "secret_version_id_is_output" {
  command = apply

  assert {
    condition = output.secret_version_id != null
    error_message = "Output `secret_version_id` was null"
  }
}

run "read_policy_is_output" {
  command = plan

  assert {
    condition = output.read_policy != null
    error_message = "Output `read_policy` was null" 
  }
}

run "write_policy_is_output" {
  command = plan

  assert {
    condition = output.write_policy != null
    error_message = "Output `write_policy` was null"
  }
}

run "type_is_output" {
  command = plan

  assert {
    condition = output._type == "aws"
    error_message = "Output `type` did not match expectations"
  }
}