run "rdbms_or_document_required" {
  command = plan

  variables {

  }

  expect_failures = [
    var.rdbms
  ]
}

run "rdbms_and_document_mutually_exclusive" {
  command = plan

  variables {
    document = { x = 1 }
    rdbms = { y = 1 }
  }

  expect_failures = [
    var.rdbms
  ]
}

