data "aws_caller_identity" "identity" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_route53_zone" "domain" {
  name = var.domain
}

data "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

data "aws_network_interface" "s3" {
  for_each = toset(data.aws_vpc_endpoint.s3.network_interface_ids)

  id = each.value
}

data "aws_cloudfront_cache_policy" "endpoint" {
  name = "Managed-CachingOptimized"
}
