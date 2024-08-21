variables {
  name = "my-lambda"
}

run "edge_lamba_and_env_vars_mutually_exclusive" {
  command = plan

  variables {
    src = "./tests/fixtures/src/"
    edge_lambda = true
    env_vars = {
      a = "b"
    }
  }

  expect_failures = [
    var.env_vars
  ]
}

run "outputs_are_set" {
  command = apply

  variables {
    src = "./tests/fixtures/src/"
  }

  assert {
    condition = output.function.invoke_arn != null && trimspace(output.function.invoke_arn) != ""
    error_message = "Output `function` does not have expected property `invoke_arn`"
  }
}