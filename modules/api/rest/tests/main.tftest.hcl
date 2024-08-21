
run "outputs-are-set" {
  command = apply

  variables {
    basepath = "./tests/fixtures/"
    name = "test"
    openapi_spec = "spec.yaml"
  }

  assert {
    condition = output.fqdn != null && trimspace(output.fqdn) != ""
    error_message = "`fqdn` output must be set"
  }
  
  assert {
    condition = toset(output.paths) == toset([
      "/pets",
      "/pets/{petId}"
    ])
    error_message = "`paths` does not match API spec"
  }

  assert {
    condition = toset(output.handlers) == toset([
      "test-listPets",
      "test-createPets",
      "test-showPetById"
    ])
    error_message = "`handlers` does not match API spec"
  }
}

run "outputs-actions" {
  command = plan

  variables {
    basepath = "./tests/fixtures/"
    name = "test"
    openapi_spec = "spec.yaml"
  }

  assert {
    condition = toset(output.actions) == toset([
      "get /pets",
      "post /pets",
      "get /pets/{petId}"
    ])
    error_message = "Output `actions` does not meet expectations: ${jsonencode(output.actions)}"
  }
}