

variables {
  service = "iam"
}

run "service_only_will_find_account_and_region" {
  command = plan

  variables {
    
  }

  assert {
    condition = provider::assert::regex("arn:aws:iam:.+?:\\d{12}:\\*", output.value)
    error_message = "Arn value did not match expectations"
  }
}

run "overriding_account_and_region_will_empty" {
  command = plan

  variables {
    region = ""
    account = ""
  }

  assert {
    condition = "arn:aws:iam:::*" == output.value
    error_message = "Arn value did not match expectations"
  }
}
