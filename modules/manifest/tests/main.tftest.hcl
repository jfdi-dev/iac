variables {
  _fail_on_error = false
}

run "manifest_path_file_does_not_exist" {
  command = plan

  variables {
    path = "tests/fixtures/does.not.exist.yaml"
  }

  expect_failures = [ var.path ]
}

run "ok_manifest_yaml" {
  command = plan

  variables {
    path = "tests/fixtures/ok.manifest.yaml"
  }

  assert { 
    condition = output.object == {
      manifest: "ok"
    }
    error_message = "Manifest did not match expectations"
  }
}

run "ok_manifest_yml" {
  command = plan

  variables {
    path = "tests/fixtures/ok.manifest.yml"
  }

  assert { 
    condition = output.object == {
      manifest: "ok"
    }
    error_message = "Manifest did not match expectations"
  }
}

run "ok_manifest_json" {
  command = plan

  variables {
    path = "tests/fixtures/ok.manifest.json"
  }

  assert { 
    condition = output.object == {
      manifest: "ok"
    }
    error_message = "Manifest did not match expectations"
  }
}

run "invalid_manifest_yml" {
  command = plan

  variables {
    path = "tests/fixtures/invalid.manifest.yml"
  }

  assert { 
    condition = local.manifest_ok == false 
    error_message = "Somehow we parsed an invalid yaml file"
  }
}

run "invalid_manifest_json" {
  command = plan

  variables {
    path = "tests/fixtures/invalid.manifest.json"
  }

  assert { 
    condition = local.manifest_ok == false 
    error_message = "Somehow we parsed an invalid json file"
  }
}
