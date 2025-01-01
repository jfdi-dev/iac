mock_provider "aws" {
  mock_data "aws_organizations_organization" {
     defaults = {
       roots = [
        {
          arn = "12345"
          name = "my_account"
          # This needs to match the regex on here: https://docs.aws.amazon.com/organizations/latest/APIReference/API_CreateOrganizationalUnit.html#organizations-CreateOrganizationalUnit-request-ParentId
          id = "r-12345|ou-a9c3-aae3r4ff9r"
        }
       ]
     }
  }
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