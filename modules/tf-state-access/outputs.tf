
output "policies" {
  value = tomap({
    state_access_policy       = aws_iam_policy.tf_state_s3_bucket_access.name,
    state_locks_access_policy = aws_iam_policy.tf_state_dynamodb_table_access.name
  })
}

output "policy_arns" {
  value = tomap({
    state_access_policy       = aws_iam_policy.tf_state_s3_bucket_access.arn,
    state_locks_access_policy = aws_iam_policy.tf_state_dynamodb_table_access.arn
  })
}