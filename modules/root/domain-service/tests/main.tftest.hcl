mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{}"
    }
  }
}

mock_provider "aws" {
  alias = "north-virginia"
}

mock_provider "auth0" {
  
}

override_module {
  target = module.manifest
  outputs = {
    object = {
      auth = {
        connections = [
          "database"
        ]
        disable_signup = false
      }
      service = {
        apis = {
          a = {
            path = "api"
            scopes = ["read:entity"]
            spec = "spec.yaml"
            src = "tests/fixtures/"
          }
        }
        statics = {
          b = {
            name = "ui"
            scopes = ["read:entity"]
            fqdn = "ui.downstream.com"
            short_name = "ui"
            path = "ui"
            src = "./src"
          }
        }
      }
      artifact = "test-app"
    }
  }
}

override_module {
  target = module.project-context
  outputs = {
    env = "test"
    value = {
      tldp1 = "mytestapp.com"
    }
  }
}

variables {
  role = "arn:aws:iam:::role/my-role"
}

run "test" {
  command = plan
}