
output s3-bucket {
  value = module.domain-service.s3-bucket
}

output cloudfront-distribution {
  value = module.domain-service.cloudfront-distribution
}
