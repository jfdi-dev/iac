

output s3-bucket {
  value = module.statics[0].bucket_name
}

output cloudfront-distribution {
  value = module.cdn.distribution-id
}
