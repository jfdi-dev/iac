mock_provider "aws" {
   mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{}"
    }
  }
}

run "test" {
  command = apply

  variables {
    file = "tests/fixtures/context-secrets.yml"
  }

  assert {
    condition = length(output.secrets) == 2
    error_message = "Not enough secrets created..."
  }
}