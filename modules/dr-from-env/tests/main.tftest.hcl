mock_provider "aws" {
  
}

run "development_is_bronze" {
  command = plan

  variables {
    env = "development"
  }

  assert {
    condition = output.level == "bronze"
    error_message = "`development` DR level was not `bronze`"
  }
}

run "dev_is_bronze" {
  command = plan

  variables {
    env = "dev"
  }

  assert {
    condition = output.level == "bronze"
    error_message = "`dev` DR level was not `bronze`"
  }
}

run "staging_is_silver" {
  command = plan

  variables {
    env = "staging"
  }

  assert {
    condition = output.level == "silver"
    error_message = "`staging` DR level was not `silver`"
  }
}

run "test_is_silver" {
  command = plan

  variables {
    env = "test"
  }

  assert {
    condition = output.level == "silver"
    error_message = "`test` DR level was not `silver`"
  }
}

run "production_is_gold" {
  command = plan

  variables {
    env = "production"
  }

  assert {
    condition = output.level == "gold"
    error_message = "`production` DR level was not `gold`"
  }
}

run "prod_is_gold" {
  command = plan

  variables {
    env = "prod"
  }

  assert {
    condition = output.level == "gold"
    error_message = "`prod` DR level was not `gold`"
  }
}

run "unknown_environment_gives_validation_error" {
  command = plan

  variables {
    env = "other"
  }

  expect_failures = [
    var.env
  ]
}
