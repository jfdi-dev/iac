mock_provider "aws" {
  
}

mock_provider "auth0" {
  override_resource {
    target = auth0_custom_domain.custom_domain[0]
    values = {
      verification = [
        {
          methods = [
            {
              name = "CNAME"
              record = "auth.abcxyz.com"
            }
          ]
        }
      ]
    }
  } 
}

variables {
  fqdn = "app.dev.test.com"
  api = {
    name = "app"
    fqdn = "api.downstream.dev"
    path = "app"
    scopes = ["read:entity"]
  }
  client = {
    name = "ui"
    fqdn = "ui.downstream.dev"
    scopes = ["write:entity", "read:entity"]
    short_name = "x"
  }
}

run "test" {
  command = apply

  assert {
    condition = output.secret_name != null
    error_message = "Output secret name was null (${output.secret_name})"
  }

  assert {
    condition = output.secret_arn != null
    error_message = "Output secret arn was null (${output.secret_arn})"
  }
}