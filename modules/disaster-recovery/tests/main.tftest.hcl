mock_provider "aws" {
  
}

run "input_validation" {
  command = plan

  variables {
    level = "platinum"
  }

  expect_failures = [
    var.level
  ]
}

run "default_level_is_bronze" {
  command = plan

  variables {

  }

  assert {
    condition = output.is_bronze == true
    error_message = "Expected default `level` to be `bronze`."
  }
}

run "bronze_outputs" {
  command = plan

  variables {
    level = "bronze"
  }

  assert {
    condition = output.is_gold == false
    error_message = "Output `is_gold` expected to be `false`"
  }

  assert {
    condition = output.is_silver == false
    error_message = "Output `is_silver` expected to be `false`"
  }

  assert {
    condition = output.is_bronze == true
    error_message = "Output `is_bronze` expected to be `true`"
  }

  assert {
    condition = output.is_at_least_silver == false
    error_message = "Output `is_at_least_silver` expected to be `false`"    
  } 
}


run "silver_outputs" {
  command = plan

  variables {
    level = "silver"
  }

  assert {
    condition = output.is_gold == false
    error_message = "Output `is_gold` expected to be `false`"
  }

  assert {
    condition = output.is_silver == true
    error_message = "Output `is_silver` expected to be `true`"
  }

  assert {
    condition = output.is_bronze == false
    error_message = "Output `is_bronze` expected to be `false`"
  }

  assert {
    condition = output.is_at_least_silver == true
    error_message = "Output `is_at_least_silver` expected to be `true`"    
  } 
}


run "gold_outputs" {
  command = plan

  variables {
    level = "gold"
  }

  assert {
    condition = output.is_gold == true
    error_message = "Output `is_gold` expected to be `true`"
  }

  assert {
    condition = output.is_silver == false
    error_message = "Output `is_silver` expected to be `false`"
  }

  assert {
    condition = output.is_bronze == false
    error_message = "Output `is_bronze` expected to be `false`"
  }

  assert {
    condition = output.is_at_least_silver == true
    error_message = "Output `is_at_least_silver` expected to be `true`"    
  } 
}