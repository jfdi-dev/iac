mock_provider "aws" {
  
}

run "creates_parameter_with_share" {
  command = plan

  variables {
    name = "hello"
    value = "world"
    shared_with = ["arn:aws:iam:eu-west-2:123456789012:root"]
  }

  assert {
    condition = output.value == { hello: "world" }
    error_message = "Output did not match expectation (${jsonencode(nonsensitive(output.value))})"
  }
}