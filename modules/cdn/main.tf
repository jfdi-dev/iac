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

resource "aws_cloudfront_distribution" "cdn" {
  
  dynamic "origin" {
    for_each = local.origins

    content {
      domain_name = origin.value.fqdn
      origin_access_control_id = aws_cloudfront_origin_access_control.oac[origin.key].id
      origin_id = origin.value.fqdn
    }
  }

  enabled = true
  is_ipv6_enabled = true
  default_root_object = local.has_static ? "index.html" : null

  logging_config {
    include_cookies = false
    bucket = "logs.${var.fqdn}"
  }

  # TODO: This should apply to the only non-prefixed static/api
  default_cache_behavior {
    allowed_methods = [ "GET", "HEAD" ]
    cached_methods = [ "GET", "HEAD" ]
    target_origin_id = local.default_origin.fqdn

    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400

    dynamic "lambda_function_association" {
      for_each = module.oidc_lambda
      iterator = edge_function

      content {
        event_type = "viewer-request"
        lambda_arn = edge_function.value.lambda_qualified_arn
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