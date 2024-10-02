provider aws {
  region = "eu-west-2"
}

variables {
  project = "jaskwa"
  email_template = "info+$${account}@jaskwa.com"
}

run "must_format_email_template" {
  command = plan

  variables {
    email_template = "info@jaskwa.com"
  }

  expect_failures = [
    var.email_template
  ]
}

run "will_create_org_structure" {
  command = plan

  assert {
    condition = local.org != null
    error_message = "Org failed to load"
  }
} 

run "will_omit_accounts_and_ous_specified_in_omit_var" {
  command = plan

  variables {
    omit = ["analytical"]
  }

  assert {
    condition = provider::assert::false(provider::assert::contains(local.units, "Analytical Workloads"))
    error_message = "Expected 'Analytical Workloads' to be omitted, but were in deployment plan"
  }
}