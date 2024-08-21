
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.62.0"
    }
    auth0 = {
      source = "auth0/auth0"
      version = ">= 1.4.0"
    }
  }
}