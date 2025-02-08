
locals {
  has_static = length(var.static) > 0
  has_api    = length(var.api) > 0

  statics = tomap({ for k, s in var.static : k => merge(s, { type = "static" }) })
  apis    = tomap({ for k, a in var.api : k => merge(a, { type = "api" }) })
  origins = merge(local.statics, local.apis)

  # Default origin is the only one without a path.
  # If all of them have a path, select the 'first' one.
  default_static_origin = one([for k, s in local.statics : s if s.path == null])
  default_api_origin    = one([for k, a in local.apis : a if a.path == null])
  default_origin        = coalesce(local.default_static_origin, local.default_api_origin, element([for k, o in local.origins : o], 0))

  domain_parts             = split(".", var.fqdn)
  domain_without_subdomain = slice(local.domain_parts, 1, length(local.domain_parts))
  zone_name                = join(".", local.domain_without_subdomain)
}

resource "aws_cloudfront_origin_access_control" "static_oac" {
  for_each = local.statics

  name                              = "s.oac.${each.value.fqdn}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_acm_certificate" "tls_cert" {
  provider = aws.tls

  domain_name       = var.fqdn
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "zone" {
  name         = local.zone_name
  private_zone = false
}

locals {
  dvo = tolist(aws_acm_certificate.tls_cert.domain_validation_options)[0]
}

resource "aws_route53_record" "cert_validation" {
  allow_overwrite = true
  name            = local.dvo.resource_record_name
  records         = [local.dvo.resource_record_value]
  ttl             = 60
  type            = local.dvo.resource_record_type
  zone_id         = data.aws_route53_zone.zone.zone_id
}

resource "aws_acm_certificate_validation" "tls_cert" {
  provider                = aws.tls
  certificate_arn         = aws_acm_certificate.tls_cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

# does this need the `tls` provider?
# data "aws_cloudfront_cache_policy" "caching_optimized" {
#   name = "Managed-CachingOptimized"
# }

resource "aws_cloudfront_distribution" "cdn" {

  depends_on = [
    aws_acm_certificate_validation.tls_cert
  ]

  dynamic "origin" {
    for_each = local.statics

    content {
      domain_name              = origin.value.fqdn
      origin_access_control_id = aws_cloudfront_origin_access_control.static_oac[origin.key].id
      origin_id                = origin.value.fqdn
    }
  }

  dynamic "origin" {
    for_each = local.apis

    content {
      # move this to rest api outputs
      domain_name = replace(origin.value.fqdn, "/^https?://([^/]*).*/", "$1")
      origin_id   = origin.value.fqdn
      # make this a param
      origin_path = "/dev"

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  aliases = [var.fqdn]

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = local.has_static ? "index.html" : null

  # logging_config {
  #   include_cookies = false
  #   # Why the suffix is required, I have no idea...
  #   bucket = "logs.${var.fqdn}.s3.amazonaws.com" 
  # }

  # TODO: This should apply to the only non-prefixed static/api
  default_cache_behavior {
    # Todo: get the data lookup working
    cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6" #data.aws_cloudfront_cache_policy.caching_optimized.id
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.default_origin.fqdn

    viewer_protocol_policy = "redirect-to-https"

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.url_rewriter.arn
    }

    dynamic "lambda_function_association" {
      for_each = var.auth_lambda_arns
      iterator = edge_function

      content {
        event_type   = "viewer-request"
        lambda_arn   = edge_function.value
        include_body = false
      }
    }
  }

  # TODO: This needs to be repeated for all none-default statics, too
  dynamic "ordered_cache_behavior" {
    for_each = local.apis
    iterator = api

    content {
      # APIs need cache disabled.
      # This policy id needs looking up:
      cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" #data.
      # And this forwards all but host header to origin...
      origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac"
      path_pattern             = "/api/${api.value.path != null ? "${api.value.path}" : "*"}"
      allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "PATCH", "DELETE", "POST"]
      cached_methods           = ["GET", "HEAD"]
      target_origin_id         = api.value.fqdn
      viewer_protocol_policy   = "https-only"

      dynamic "lambda_function_association" {
        for_each = var.auth_lambda_arns
        iterator = edge_function

        content {
          event_type   = "origin-request"
          lambda_arn   = edge_function.value
          include_body = false
        }
      }

      # forwarded_values {
      #   query_string = true
      #   cookies {
      #     forward = "all"
      #   }
      # }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.tls_cert.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  # todo: set this via var?
  price_class = "PriceClass_100"
}

data "aws_iam_policy_document" "bucket_policy" {
  for_each = local.statics
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions = ["s3:GetObject"]
    resources = [
      "arn:aws:s3:::${each.value.bucket_name}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cdn.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "content" {
  for_each = local.statics
  bucket   = each.value.bucket_name
  policy   = data.aws_iam_policy_document.bucket_policy[each.key].json
}

resource "aws_cloudfront_function" "url_rewriter" {
  name    = "url-rewriter"
  runtime = "cloudfront-js-2.0"
  publish = true
  code    = file("${path.module}/url-rewriter.js")
}