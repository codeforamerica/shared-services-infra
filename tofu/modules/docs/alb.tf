module "endpoint_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3"

  name   = "${local.prefix}-endpoint"
  vpc_id = var.vpc_id

  # Ingress for HTTP
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]

  # Allow egress to the S3 endpoints.
  egress_cidr_blocks = [for ip in local.s3_ips : "${ip}/32"]
  egress_rules       = ["https-443-tcp"]

  tags = local.tags
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.17"

  name                       = local.prefix
  enable_deletion_protection = !var.force_delete
  load_balancer_type         = "application"
  security_groups            = [module.endpoint_security_group.security_group_id]
  subnets                    = var.public_subnets
  vpc_id                     = var.vpc_id
  internal                   = false

  access_logs = {
    bucket  = var.logging_bucket
    enabled = true
  }

  connection_logs = {
    bucket  = var.logging_bucket
    enabled = true
  }

  # TODO: Support IPv6 and/or dualstack.
  ip_address_type = "ipv4"

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    https = {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"
      certificate_arn = aws_acm_certificate.endpoint.arn
      forward = {
        target_group_key = "endpoint"
      }
    }
  }

  target_groups = {
    endpoint = {
      name        = local.prefix
      protocol    = "HTTPS"
      target_type = "ip"
      port        = 443

      # We have multiple IPs to attach, so we'll create the attachments
      # ourselves.
      create_attachment = false

      health_check = {
        healthy_threshold   = 5
        protocol            = "HTTPS"
        unhealthy_threshold = 2
        success_codes       = "200,307,405"
      }
    }
  }

  additional_target_group_attachments = { for ip in local.s3_ips : ip => {
    target_group_key = "endpoint"
    target_id        = ip
    port             = 443
  } }

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

resource "aws_route53_record" "endpoint" {
  name    = local.fqdn
  type    = "A"
  zone_id = data.aws_route53_zone.domain.zone_id

  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
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
