
output "s3-bucket" {
  value = module.static.bucket_name
}

output "cloudfront-distribution" {
  value = module.cdn.distribution-id
}
