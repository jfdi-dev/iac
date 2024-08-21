run "manifest_construction_process" {
  command = plan

  variables {
    path = "./tests/fixtures/src/handlers/f1/"
  }

  assert {
    condition = local.p1 == tolist([
      ".",
      "tests",
      "fixtures",
      "src",
      "handlers",
      "f1"
    ])
    error_message = "p1 error"
  }

  assert {
    condition = local.p2 == [
      tolist(["."]),
      tolist([".", "tests"]),
      tolist([".", "tests", "fixtures"]),
      tolist([".", "tests", "fixtures", "src"]),
      tolist([".", "tests", "fixtures", "src", "handlers"]),
      tolist([".", "tests", "fixtures", "src", "handlers", "f1"])
    ]
    error_message = "p2 error"
  }

  assert {
    condition = local.p3 == [
      "./",
      "./tests/",
      "./tests/fixtures/",
      "./tests/fixtures/src/",
      "./tests/fixtures/src/handlers/",
      "./tests/fixtures/src/handlers/f1/"
    ]
    error_message = "p3 error"
  }

  assert {
    condition = local.p4 == [
      null,
      null,
      null,
      {
        runtime = {
          name = "nodejs20.x"
          timeout = 35
          memory_size = 512
        }
        concurrency = {
          reserved = 250
          provisioned = 20
        }
        iam_role_statements = [
          {
            effect = "allow"
            actions = ["s3:ListBuckets"]
            resources = ["www.mybucket.com"]
          }
        ]
      },
      null,
      null
    ]
    error_message = "p4 error"
  }

  # # What's up with this guy?
  # assert {
  #   condition = local.p5 == [
  #     {
  #       runtime = {
  #         name = "nodejs20.x"
  #         timeout = 30
  #         memory_size = 512
  #       }
  #       concurrency = {
  #         provisioned = 0
  #         reserved = -1
  #       }
  #       iam_role_statements = [ ]
  #     },
  #     {
  #       runtime = {
  #         name = "nodejs20.x"
  #         timeout = 35
  #         memory_size = 512
  #       }
  #       concurrency = {
  #         provisioned = 20
  #         reserved = 250
  #       }
  #       iam_role_statements = [
  #         {
  #           effect = "allow"
  #           actions = ["s3:ListBuckets"]
  #           resources = ["www.mybucket.com"]
  #         }
  #       ]
  #     }
  #   ]
  #   error_message = "p5 error: ${jsonencode(local.p5)}"
  # }

  assert {
    condition = output.settings == {
      runtime = {
        name = "nodejs20.x"
        timeout = 35
        memory_size = 512
      }
      concurrency = {
        reserved = 250
        provisioned = 20
      }
      iam_role_statements = [
        {
          effect = "allow"
          actions = ["s3:ListBuckets"]
          resources = ["www.mybucket.com"]
        }
      ]
    }
    error_message = "Calculated manifest does not match expectations."
  }
}

run "manifest_merging" {
  command = plan

  variables {
    path = "./tests/fixtures/src/handlers/f2/"
  } 

  assert {
    condition = output.settings == {
      runtime = {
        name = "nodejs18.x"
        memory_size = 1024
        timeout = 35
      }
      concurrency = {
        reserved = 250
        provisioned = 25
      }
      iam_role_statements = [
        {
          effect = "allow"
          actions = ["s3:ListBuckets"]
          resources = ["www.mybucket.com"]
        }
      ]
    }
    error_message = "Merged manifest does not match expectations."
  }
}

run "manifest_permissions_merging" {
  command = plan

  variables {
    path = "./tests/fixtures/src/handlers/f3/"
  } 

  assert {
    condition = output.settings == {
      runtime = {
        name = "nodejs20.x"
        timeout = 35
        memory_size = 512
      }
      concurrency = {
        reserved = 250
        provisioned = 20
      }
      iam_role_statements = [
        {
          effect = "allow"
          actions = ["s3:ListBuckets"]
          resources = ["www.mybucket.com"]
        },
        {
          effect = "allow"
          actions = ["s3:CreateBucket"]
          resources = ["docs.mybucket.com"]
        }
      ]
    }
    error_message = "Merged manifest does not match expectations."
  }
}


run "manifest_can_be_json" {
  command = plan

  variables {
    path = "./tests/fixtures/src/handlers/f4/"
  } 

  assert {
    condition = output.settings == {
      runtime = {
        name = "python2.1"
        timeout = 111
        memory_size = 512
      }
      concurrency = {
        reserved = 300
        provisioned = 20
      }
      iam_role_statements = [
        {
          effect = "allow"
          actions = ["s3:ListBuckets"]
          resources = ["www.mybucket.com"]
        },
        {
          effect = "allow"
          actions = ["iam:CreateRole"]
          resources = ["*"]
        }
      ]
    }
    error_message = "Merged manifest does not match expectations."
  }
}
