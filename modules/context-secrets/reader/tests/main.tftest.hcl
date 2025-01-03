mock_provider "aws" {
  mock_data "aws_secretsmanager_secret_version" {
    defaults = {
      arn = "12345"
      name = "abc123"
    }
  }

  override_data {
    target = data.aws_secretsmanager_secret_version.context_secrets["a"]
    values = {
      secret_string = "aaaaa"
    }
  }

  override_data {
    target = data.aws_secretsmanager_secret_version.context_secrets["b"]
    values = {
      secret_string = "bbbbb"
    }
  }

  override_data {
    target = data.aws_secretsmanager_secret_version.context_secrets["c"]
    values = {
      secret_string = "ccccc"
    }
  }
}

variables {
  context_secrets = ["a", "b", "c"]
}

run "outputs_the_read_secrets_as_map" {
  command = plan

  assert { 
    condition = output.context_secrets != null
    error_message = "Context secrets were not output"
  }

  assert {
    condition = length(keys(output.context_secrets)) == 3
    error_message = "Not all context secrets were output"
  }

  assert {
    condition = contains(keys(output.context_secrets), "a")
    error_message = "The secret `a` was missing from output"
  }

  assert {
    condition = output.context_secrets["a"] == "aaaaa"
    error_message = "The secret `a` did not have the expected value (${nonsensitive(output.context_secrets["a"])})"
  }

  assert {
    condition = contains(keys(output.context_secrets), "b")
    error_message = "The secret `b` was missing from output"
  }

  assert {
    condition = output.context_secrets["b"] == "bbbbb"
    error_message = "The secret `b` did not have the expected value (${nonsensitive(output.context_secrets["b"])})"
  }

  assert {
    condition = contains(keys(output.context_secrets), "c")
    error_message = "The secret `c` was missing from output"
  }

  assert {
    condition = output.context_secrets["c"] == "ccccc"
    error_message = "The secret `c` did not have the expected value (${nonsensitive(output.context_secrets["c"])})"
  }

  assert {
    condition = !contains(keys(output.context_secrets), "d")
    error_message = "The secret `d` was erroneously included in output"
  }
}
