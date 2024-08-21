
run "outputs-are-set" {
  command = apply

  variables {
    name = "test"
    src = "./tests/fixtures/"
    functions = [
      "listPets",
      "createPets",
      "showPetById"
    ]
  }

  assert {
    condition = toset([ for h in output.handlers: h.function_name ]) == toset([
      "test-listPets",
      "test-createPets",
      "test-showPetById"
    ])
    error_message = "Outputs `handlers` does not match input `functions`"
  }

  assert {
    condition = alltrue([ for handler in output.handlers: trimspace(handler.invoke_arn) != null ])
    error_message = "`invoke_arn` is missing from one or more output `handlers`."
  }
}