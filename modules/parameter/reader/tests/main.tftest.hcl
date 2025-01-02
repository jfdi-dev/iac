mock_provider "aws" {
  alias = "tags"
  mock_data "aws_ram_resource_share" {
    defaults = {
      resource_arns = ["12345", "54321"]
    }
  }
  mock_data "aws_ssm_parameter" {
    defaults = {
      insecure_value = "Hello!"
      value = "Hello!"
    }
  }
}

mock_provider "aws" {
  alias = "name"
  mock_data "aws_ram_resource_share" {
    defaults = {
      resource_arns = ["12345"]
    }
  }
  mock_data "aws_ssm_parameter" {
    defaults = {
      insecure_value = "Hi!"
      value = "Hi!"
    }
  }
}

run "can_get_existing_parameters_by_tags" {
  command = plan

  providers = {
    aws = aws.tags
  }

  variables {
    tags = {
      a: ["1"]
    }
  }

  assert {
    condition = output.value == {
      "12345": "Hello!"
      "54321": "Hello!"
    }
    error_message = "Output value was not as expected (${jsonencode(nonsensitive(output.value))})"
  }
}

run "can_get_an_existing_parameter_by_name" {
  command = plan

  providers = {
    aws = aws.name
  }
  
  variables {
    name = "a"
  }

  assert {
    condition = output.value == {
      "12345": "Hi!"
    }
    error_message = "Output value was not as expected (${jsonencode(nonsensitive(output.value))})"
  }
}

run "one_of_tags_or_name_is_required" {
  command = plan

  providers = {
    aws = aws.name
  }

  expect_failures = [ var.name ]
}

run "only_one_of_tags_or_name_is_supported" {
  command = plan

  providers = {
    aws = aws.name
  }

  variables {
    name = "something"
    tags = { a: ["b"] }
  }

  expect_failures = [ var.name ]
}