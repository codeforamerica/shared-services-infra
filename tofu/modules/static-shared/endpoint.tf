resource "aws_cloudfront_origin_request_policy" "endpoint" {
  name    = "${local.prefix}-endpoint"
  comment = "Forward the viewer Host header to the origin-request rewrite function."

  cookies_config {
    cookie_behavior = "none"
  }

  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["Host"]
    }
  }

  query_strings_config {
    query_string_behavior = "none"
  }
}

resource "aws_cloudfront_origin_access_control" "endpoint" {
  name                              = "${local.prefix}-endpoint"
  description                       = "Authorize CloudFront to serve content from the static apps S3 bucket."
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# TODO: Use a WAF?
#trivy:ignore:AVD-AWS-0011
#trivy:ignore:AVD-AWS-0010
resource "aws_cloudfront_distribution" "endpoint" {
  depends_on = [aws_lambda_function.oidc, aws_lambda_function.rewrite]

  enabled             = true
  comment             = "Serve static apps from S3."
  is_ipv6_enabled     = true
  aliases             = [local.apps_domain, "*.${local.apps_domain}"]
  price_class         = "PriceClass_100"
  default_root_object = "index.html"

  origin {
    domain_name              = module.bucket.bucket_regional_domain_name
    origin_id                = local.prefix
    origin_access_control_id = aws_cloudfront_origin_access_control.endpoint.id
  }

  logging_config {
    include_cookies = false
    bucket          = "${var.logging_bucket}.s3.amazonaws.com"
    prefix          = "cloudfront/${local.apps_domain}"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.prefix
    compress         = true
    default_ttl      = 0
    max_ttl          = 0
    min_ttl          = 0

    cache_policy_id          = data.aws_cloudfront_cache_policy.endpoint.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.endpoint.id
    viewer_protocol_policy   = "redirect-to-https"

    lambda_function_association {
      event_type   = "viewer-request"
      lambda_arn   = aws_lambda_function.oidc.qualified_arn
      include_body = false
    }

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_function.rewrite.qualified_arn
      include_body = false
    }
  }

  # Return a friendly 404 page for missing content or unknown app subdomains.
  custom_error_response {
    error_code            = 403
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 10
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.endpoint.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = local.tags
}

resource "aws_acm_certificate" "endpoint" {
  domain_name               = local.apps_domain
  subject_alternative_names = ["*.${local.apps_domain}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

resource "aws_route53_record" "endpoint_validation" {
  for_each = {
    for dvo in aws_acm_certificate.endpoint.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.domain.zone_id
}

resource "aws_acm_certificate_validation" "endpoint" {
  certificate_arn = aws_acm_certificate.endpoint.arn
  validation_record_fqdns = [
    for record in aws_route53_record.endpoint_validation : record.fqdn
  ]
}

# Exact record for the shared root domain (apps.{domain}).
resource "aws_route53_record" "endpoint" {
  for_each = toset(["A", "AAAA"])

  name    = local.apps_domain
  type    = each.value
  zone_id = data.aws_route53_zone.domain.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.endpoint.domain_name
    zone_id                = aws_cloudfront_distribution.endpoint.hosted_zone_id
  }
}

# Wildcard record routes all app subdomains (*.apps.{domain}) to the same distribution.
resource "aws_route53_record" "wildcard" {
  for_each = toset(["A", "AAAA"])

  name    = "*.${local.apps_domain}"
  type    = each.value
  zone_id = data.aws_route53_zone.domain.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.endpoint.domain_name
    zone_id                = aws_cloudfront_distribution.endpoint.hosted_zone_id
  }
}
