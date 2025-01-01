mock_provider "aws" {
  
}

run "artifact_set_in_manifest_is_ok" {
  command = plan

  variables {
    manifest_path = "./tests/fixtures/has_artifact.yml"
  }

  assert {
    condition = output.artifact == "app"
    error_message = "Artifact name was not set in manifest object"
  }
}

run "artifact_unset_in_manifest_is_an_error" {
  command = plan

  variables {
    manifest_path = "./tests/fixtures/no_artifact.yml"
  }

  expect_failures = [ 
    output.artifact
  ]
}

run "deployment_sets_defaults_when_omitted_from_manifest" {
  command = plan

  variables {
    manifest_path = "./tests/fixtures/has_artifact.yml"
  }

  assert {
    condition = output.deployment == {
      policies = {
        custom = {}
        named = []
        managed = []
        service = []
      }
    }
    error_message = "Deployment defaults were not set (${jsonencode(output.deployment)})"
  }
}

run "secrets_is_empty_set_when_omitted_from_manifest" {
  command = plan

  variables {
    manifest_path = "./tests/fixtures/has_artifact.yml"
  }

  assert {
    condition = length(output.secrets) == 0
    error_message = "Manifest did not contain an empty set of secrets"
  }
}