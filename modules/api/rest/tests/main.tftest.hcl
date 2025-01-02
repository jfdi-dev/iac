mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{}"
    }
  }
  mock_data "aws_api_gateway_authorizers" {
    defaults = {
      ids = ["12345"]
    }
  }
  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam:eu-west-2:123456789012:role/my-role"
    }
  }
  mock_resource "aws_api_gateway_rest_api" {
    defaults = {
      execution_arn = "arn:aws:apigateway:eu-west-2:123456789012:api"
    }
  }
}
mock_provider "aws" {
  alias = "tls"
}

override_module {
  target = module.jwt-auth
  outputs = {
    function = {
      invoke_arn = "arn:aws:lambda:eu-west-2:123456789012:function/my-func"
      function_name = "my-func"
    }
  }

}

run "outputs-are-set" {
  command = apply

  variables {
    basepath = "./tests/fixtures/"
    name = "test"
    env = "local"
    openapi_spec = "spec.yaml"
  }

  assert {
    condition = output.fqdn != null && trimspace(output.fqdn) != ""
    error_message = "`fqdn` output must be set"
  }
  
  assert {
    condition = toset(output.paths) == toset([
      "/pets",
      "/pets/{petId}"
    ])
    error_message = "`paths` does not match API spec"
  }

  assert {
    condition = toset(output.handlers) == toset([
      "test-listPets",
      "test-createPets",
      "test-showPetById"
    ])
    error_message = "`handlers` does not match API spec"
  }
}

run "outputs-actions" {
  command = apply

  variables {
    basepath = "./tests/fixtures/"
    name = "test"
    env = "local"
    openapi_spec = "spec.yaml"
  }

  assert {
    condition = toset(output.actions) == toset([
      "get /pets",
      "post /pets",
      "get /pets/{petId}"
    ])
    error_message = "Output `actions` does not meet expectations: ${jsonencode(output.actions)}"
  }
}