resource "aws_cloudfront_origin_access_control" "endpoint" {
  name                              = "${local.prefix}-endpoint"
  description                       = "Authorize CloudFront to serve content from the documentation S3 bucket."
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_function" "endpoint_rewrite" {
  name    = "cfa-documentation-${var.environment}-rewrite"
  comment = "Rewrite requests to direct to the index.html file in the S3 bucket."
  runtime = "cloudfront-js-2.0"
  publish = true

  code = file("${local.file_dir}/rewrite-function.js")

  lifecycle {
    create_before_destroy = true
  }
}

# TODO: Use a WAF?
#trivy:ignore:AVD-AWS-0011
#trivy:ignore:AVD-AWS-0010
resource "aws_cloudfront_distribution" "endpoint" {
  depends_on = [aws_lambda_function.oidc]

  enabled             = true
  comment             = "Serve static documentation from S3."
  is_ipv6_enabled     = true
  aliases             = [local.fqdn]
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
    prefix          = "cloudfront/${local.fqdn}"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.prefix
    compress         = true
    default_ttl      = 0
    max_ttl          = 0
    min_ttl          = 0

    cache_policy_id        = data.aws_cloudfront_cache_policy.endpoint.id
    viewer_protocol_policy = "redirect-to-https"

    lambda_function_association {
      event_type   = "viewer-request"
      lambda_arn   = aws_lambda_function.oidc.qualified_arn
      include_body = false
    }
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
  domain_name       = local.fqdn
  validation_method = "DNS"

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

resource "aws_route53_record" "endpoint" {
  for_each = toset(["A", "AAAA"])

  name    = local.fqdn
  type    = each.value
  zone_id = data.aws_route53_zone.domain.zone_id

  alias {
    # CloudFront doesn't provide a health check.
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.endpoint.domain_name
    zone_id                = aws_cloudfront_distribution.endpoint.hosted_zone_id
  }
}
