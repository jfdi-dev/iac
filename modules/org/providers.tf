
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.62.0"
    }
    assert = {
      source = "hashicorp/assert"
    }
  }
}