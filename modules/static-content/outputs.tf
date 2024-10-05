
output "_tag" {
  value = "static"
}

output "fqdn" {
  value = aws_s3_bucket.content.bucket_regional_domain_name
}

output bucket_name {
  value = aws_s3_bucket.content.bucket
}

output "bucket_id" {
  value = aws_s3_bucket.content.id
}

output "bucket_arn" {
  value = aws_s3_bucket.content.arn
}

output "logs_bucket_id" {
  value = aws_s3_bucket.logs.id
}

output "logs_bucket_arn" {
  value = aws_s3_bucket.logs.arn
}
