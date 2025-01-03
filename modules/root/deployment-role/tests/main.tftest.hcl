mock_provider "aws" {
  
}

override_module {
  target = module.project-context
  outputs = {
    value = {
      project = "test-project"
      accounts = {
        tooling = "t"
        networking = "n"
        security = "s"
        dev = "d"
        test = "te"
        prod = "p"
      }
    }
    env = "dev"
  }
}

override_module {
  target = module.manifest
  outputs = {
    artifact = "test-app"
    secrets = [
      "a", "b", "c"
    ]
    deployment = {
      policies = {
        named = [ "pn1", "pn2", "pn3" ]
        service = [ "ps1", "ps2", "ps3" ]
        managed = [ "pm1", "pm2", "pm3" ]
      }
    }
  }
}

run "outputs_generated_role_arn" {
  command = apply

  assert {
    condition = output.role_arn != null
    error_message = "No role was output"
  }
}