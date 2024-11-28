

output s3-bucket {
  value = module.statics.bucket_name
}

output cloudfront-distribution {
  value = module.cdn.distribution-id
}
