
output tf_state_s3_bucket_name {
  value = aws_s3_bucket.terraform_state.bucket
}

output tf_state_s3_bucket_arn {
  value = aws_s3_bucket.terraform_state.arn
}

output tf_state_locks_dynamodb_table_name {
  value = aws_dynamodb_table.terraform_state_locks.name
}

output tf_state_locks_dynamodb_table_arn {
  value = aws_dynamodb_table.terraform_state_locks.arn
}
