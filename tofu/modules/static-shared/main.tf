module "secrets" {
  source = "github.com/codeforamerica/tofu-modules-aws-secrets?ref=2.1.1"

  project     = var.project
  environment = var.environment
  add_suffix  = false

  secrets = {
    OIDC_SETTINGS = {
      description = "OIDC credentials for static app hosting"
      start_value = jsonencode({
        client_id     = "abc",
        client_secret = "123",
      })
    }
  }

  tags = local.tags
}

module "doppler" {
  source     = "github.com/codeforamerica/tofu-modules-aws-doppler?ref=1.1.0"
  depends_on = [module.secrets]

  project              = var.project
  environment          = var.environment
  kms_key_arns         = [module.secrets.kms_key_arn]
  doppler_project      = "shared-static-hosting"
  doppler_workspace_id = var.doppler_workspace_id
  tags                 = local.tags
}

resource "aws_kms_key" "static" {
  description         = "Encryption key for static application hosting"
  enable_key_rotation = true

  tags = local.tags
}

# Managed separately so the KMS key can be created before CloudFront exists,
# breaking the kms_key → cloudfront → bucket_policy → kms_key_policy cycle.
resource "aws_kms_key_policy" "static" {
  key_id = aws_kms_key.static.id
  policy = jsonencode(yamldecode(templatefile("${local.template_dir}/key-policy.yaml.tftpl", {
    account                     = data.aws_caller_identity.identity.account_id,
    partition                   = data.aws_partition.current.partition,
    prefix                      = local.prefix,
    bucket_name                 = var.project,
    cloudfront_distribution_arn = aws_cloudfront_distribution.endpoint.arn,
  })))
}

resource "aws_kms_alias" "static" {
  name          = "alias/${var.project}/${var.environment}/static-hosting"
  target_key_id = aws_kms_key.static.id
}

module "bucket" {
  source  = "boldlink/s3/aws"
  version = "~> 2.5.0"

  bucket                 = "static.${var.domain}"
  sse_sse_algorithm      = "aws:kms"
  sse_bucket_key_enabled = true
  sse_kms_master_key_arn = aws_kms_key.static.arn
  versioning_status      = "Enabled"
  force_destroy          = var.force_delete

  s3_logging = {
    target_bucket = var.logging_bucket
    target_prefix = "${local.aws_logs_path}/s3accesslogs/${local.prefix}/"
  }

  lifecycle_configuration = [{
    id                                     = "static-hosting"
    status                                 = "Enabled"
    prefix                                 = ""
    abort_incomplete_multipart_upload_days = 7
    noncurrent_version_expiration = {
      noncurrent_days = 30
    }
  }]

  tags = merge(local.tags, { use = "static-site" })
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket = module.bucket.bucket
  policy = jsonencode(yamldecode(templatefile("${local.template_dir}/bucket-policy.yaml.tftpl", {
    bucket_arn                  = module.bucket.arn,
    vpc_endpoint_id             = data.aws_vpc_endpoint.s3.id,
    cloudfront_distribution_arn = aws_cloudfront_distribution.endpoint.arn,
  })))
}

resource "aws_s3_object" "robots" {
  bucket        = module.bucket.bucket
  key           = "robots.txt"
  source        = "${local.file_dir}/robots.txt"
  force_destroy = var.force_delete

  tags = local.tags
}

resource "aws_s3_object" "index" {
  bucket        = module.bucket.bucket
  key           = "index.html"
  source        = "${local.file_dir}/index.html"
  content_type  = "text/html"
  force_destroy = var.force_delete

  tags = local.tags
}

resource "aws_s3_object" "not_found" {
  bucket        = module.bucket.bucket
  key           = "404.html"
  source        = "${local.file_dir}/404.html"
  content_type  = "text/html"
  force_destroy = var.force_delete

  tags = local.tags
}
