
output "_tag" {
  value = "cloudfront"
}

output "dns_name" {
  value = aws_cloudfront_distribution.cdn.domain_name
}
