locals {
  has_static = length(var.static) > 0
  has_api = length(var.api) > 0

  statics = [ for s in var.static: merge(s, { type = "static" }) ]
  apis = [ for a in var.api: merge(a, { type = "api" }) ]
  origins = concat(local.statics, local.apis)

  non_prefixed_origin = [
    for o in local.origins: o if o.path == null
  ]

  default_origin = coalesce(
    length(local.non_prefixed_origin) > 0 ? local.non_prefixed_origin[0] : null, 
    length(local.origins) > 0 ? local.origins[0] : null
  )

  domain_parts = split(".", var.fqdn)
  domain_without_subdomain = slice(local.domain_parts, 1, length(local.domain_parts))
  zone_name = join(".", local.domain_without_subdomain)
}

module "oidc_lambda" {
  count = var.protected ? 1 : 0
  source = "../lambda/auth/oidc"

  providers = { 
    aws = aws.edge
  }
}

resource "aws_cloudfront_origin_access_control" "oac" {
  for_each = { for idx, origin in local.origins: idx => origin }

  name = "oac.${each.value.fqdn}"
  origin_access_control_origin_type = each.value.type == "static" ? "s3" : "lambda"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}

resource "aws_acm_certificate" "tls_cert" {
  provider = aws.tls
  
  domain_name = var.fqdn
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "zone" {
  name = local.zone_name
  private_zone = false
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.tls_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone.id
}

resource "aws_acm_certificate_validation" "tls_cert" {
  provider = aws.tls
  certificate_arn         = aws_acm_certificate.tls_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# data "aws_cloudfront_cache_policy" "caching_optimized" {
#   name = "Managed-CachingOptimized"
# }

resource "aws_cloudfront_distribution" "cdn" {

  depends_on = [  aws_acm_certificate_validation.tls_cert ]
  
  dynamic "origin" {
    for_each = local.origins

    content {
      domain_name = origin.value.fqdn
      origin_access_control_id = aws_cloudfront_origin_access_control.oac[origin.key].id
      origin_id = origin.value.fqdn
    }
  }

  aliases = [ var.fqdn ]

  enabled = true
  is_ipv6_enabled = true
  default_root_object = local.has_static ? "index.html" : null

  logging_config {
    include_cookies = false
    # Why the suffix is required, I have no idea...
    bucket = "logs.${var.fqdn}.s3.amazonaws.com" 
  }

  # TODO: This should apply to the only non-prefixed static/api
  default_cache_behavior {
    # Todo: get the data lookup working
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" #data.aws_cloudfront_cache_policy.caching_optimized.id
    allowed_methods = [ "GET", "HEAD" ]
    cached_methods = [ "GET", "HEAD" ]
    target_origin_id = local.default_origin.fqdn

    viewer_protocol_policy = "redirect-to-https"

    dynamic "lambda_function_association" {
      for_each = module.oidc_lambda
      iterator = edge_function

      content {
        event_type = "viewer-request"
        lambda_arn = edge_function.value.function.function.qualified_arn
        include_body = false
      }
    }
  }

  # TODO: This needs to be repeated for all none-default statics, too
  dynamic "ordered_cache_behavior" {
    for_each = local.apis
    iterator = api

    content {
      path_pattern = "/api/${api.value.path != null ? "${api.value.path}/" : ""}"
      allowed_methods = [ "GET", "HEAD", "OPTIONS", "PUT", "PATCH", "DELETE", "POST" ]
      cached_methods = [ "GET", "HEAD" ]
      target_origin_id = api.value.fqdn
      viewer_protocol_policy = "https-only"
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.tls_cert.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method = "sni-only"
  }

  # todo: set this via var?
  price_class = "PriceClass_100"
}

data aws_iam_policy_document bucket_policy {
  statement {
    principals {
      type = "Service"
      identifiers = [ "cloudfront.amazonaws.com" ]
    }
    actions = [ "s3:GetObject" ]
    resources = [ "arn:aws:s3:::${var.fqdn}/*" ]
    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = [ aws_cloudfront_distribution.cdn.arn ]
    }
  }
}

resource aws_s3_bucket_policy content {
  bucket = var.fqdn
  policy = data.aws_iam_policy_document.bucket_policy.json
}
