mock_provider "aws" {
  
}

run "outputs_are_set" {
  command = apply

  variables {
    name = "www.dev.example.com"
  }

  assert {
    condition = output._tag == "static"
    error_message = "Output `_tag` does not equal 'static' ('${output._tag}')"
  }

  assert {
    condition = output.fqdn != null && trimspace(output.fqdn) != ""
    error_message = "Output `fqdn` does not match expectations ('${output.fqdn}')"
  }

  assert {
    condition = output.bucket_id != null && trimspace(output.bucket_id) != ""
    error_message = "Output `bucket_id` does not match expectations ('${output.bucket_id}')"
  }

  assert { 
    condition = output.bucket_arn != null && trimspace(output.bucket_id) != ""
    error_message = "Output `bucket_arn` does not match expectations ('${output.bucket_arn}')"
  }

  assert {
    condition = output.logs_bucket_id != null && trimspace(output.logs_bucket_id) != ""
    error_message = "Output `logs_bucket_id` does not match expectations ('${output.logs_bucket_id}')"
  }

  assert {
    condition = output.logs_bucket_arn != null && trimspace(output.logs_bucket_arn) != ""
    error_message = "Output `logs_bucket_arn` does not match expectations ('${output.logs_bucket_arn}')"
  }
}