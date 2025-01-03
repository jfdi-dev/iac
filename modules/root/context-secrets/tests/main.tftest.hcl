mock_provider "aws" {
  mock_data "aws_secretsmanager_secret_version" {
    defaults = {
      arn = "12345"
      name = "abc"
      secret_string = "xyz890"
    }
  }
}

override_module {
  target = module.context-secrets
  outputs = {
    context_secrets = {
      auth0 = "abcde"
      stripe = "fghij"
      openai = "klmno"
    }
  }
}

override_module {
  target = module.manifest
  outputs = {
    artifact = "test"
    secrets = [
      "auth0",
      "stripe",
      "openai"
    ]
  }
}

variables {
  role = "test"
}

run "outputs_the_context_secret" {
  command = plan

  assert {
    condition = output.context_secrets != null
    error_message = "The context secret was not included in output"
  }

  assert {
    condition = length(keys(output.context_secrets)) == 3
    error_message = "Expected 3 secrets in output, got too many (${jsonencode(nonsensitive(output.context_secrets))})"
  }

  assert {
    condition = contains(keys(output.context_secrets), "auth0")
    error_message = "The `auth0` context secret was not included in output (${jsonencode(nonsensitive(output.context_secrets))})"
  }

  assert {
    condition = output.context_secrets["auth0"] == "abcde"
    error_message = "The `auth0` context secret was not included in output (${jsonencode(nonsensitive(output.context_secrets))})"
  }

  assert {
    condition = contains(keys(output.context_secrets), "stripe")
    error_message = "The `stripe` context secret was not included in output (${jsonencode(nonsensitive(output.context_secrets))})"
  }

  assert {
    condition = output.context_secrets["stripe"] == "fghij"
    error_message = "The `stripe` context secret was not included in output (${jsonencode(nonsensitive(output.context_secrets))})"
  }

  assert {
    condition = contains(keys(output.context_secrets), "openai")
    error_message = "The `openai` context secret was not included in output (${jsonencode(nonsensitive(output.context_secrets))})"
  }

  assert {
    condition = output.context_secrets["openai"] == "klmno"
    error_message = "The `openai` context secret was not included in output (${jsonencode(nonsensitive(output.context_secrets))})"
  }
}