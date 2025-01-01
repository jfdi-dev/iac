run "name_cannot_be_empty" {
  command = plan

  variables {
    name = ""
  }

  expect_failures = [ 
    var.name
  ]
}

run "value_cannot_be_empty" {
  command = plan

  variables {
    value = ""
  }

  expect_failures = [ 
    var.value
  ]
}