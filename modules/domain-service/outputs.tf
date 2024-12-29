

output "s3-bucket" {
  value = [
    for k, v in module.statics : v.bucket_name
  ][0]
}

output "cloudfront-distribution" {
  value = module.cdn.distribution-id
}
