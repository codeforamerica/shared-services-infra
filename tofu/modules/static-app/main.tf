module "secrets" {
  source = "github.com/codeforamerica/tofu-modules-aws-secrets?ref=2.0.0"

  project     = local.project
  environment = var.environment
  add_suffix  = false

  secrets = {
    OIDC_SETTINGS = {
      description = "OIDC credentials for static app hosting"
      type        = "json"
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

  project              = local.project
  environment          = var.environment
  kms_key_arns         = [module.secrets.kms_key_arn]
  doppler_workspace_id = "08430c37e2a2889dc220"
  tags                 = local.tags
}


resource "aws_servicecatalogappregistry_application" "static" {
  name        = local.prefix
  description = "Static app hosting (${var.project}) for Code for America."

  tags = local.tags_base
}

resource "aws_kms_key" "static" {
  description         = "Encryption key for static app hosting"
  enable_key_rotation = true

  tags = local.tags
}

# Managed separately so the KMS key can be created before CloudFront exists,
# breaking the kms_key → cloudfront → app_bucket → kms_key cycle.
resource "aws_kms_key_policy" "static" {
  key_id = aws_kms_key.static.id
  policy = jsonencode(yamldecode(templatefile("${local.template_dir}/key-policy.yaml.tftpl", {
    account_id  : data.aws_caller_identity.identity.account_id,
    partition   : data.aws_partition.current.partition,
    prefix      : local.prefix,
    bucket_names : concat(
      [var.bucket_name],
      [for k in keys(local.apps) : "${local.prefix}-${k}"]
    ),
    cloudfront_distribution_arn : aws_cloudfront_distribution.endpoint.arn,
  })))
}

resource "aws_kms_alias" "static" {
  name          = "alias/${var.project}/${var.environment}"
  target_key_id = aws_kms_key.static.id
}

module "bucket" {
  source  = "boldlink/s3/aws"
  version = "~> 2.5.0"

  bucket                 = var.bucket_name
  sse_sse_algorithm      = "aws:kms"
  sse_bucket_key_enabled = true
  sse_kms_master_key_arn = aws_kms_key.static.arn
  versioning_status      = "Enabled"
  force_destroy          = var.force_delete

  s3_logging = {
    target_bucket = var.logging_bucket
    target_prefix = "${local.aws_logs_path}/s3accesslogs/${var.bucket_name}"
  }

  lifecycle_configuration = [{
    id                                     = "static-site"
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
    bucket_arn                  : module.bucket.arn,
    vpc_endpoint_id             : data.aws_vpc_endpoint.s3.id,
    cloudfront_distribution_arn : aws_cloudfront_distribution.endpoint.arn,
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
  bucket         = module.bucket.bucket
  key            = "index.html"
  content_base64 = base64encode(templatefile("${local.template_dir}/index.html.tftpl", { apps = local.apps }))
  content_type   = "text/html"
  force_destroy  = var.force_delete

  tags = local.tags
}

module "app_bucket" {
  for_each = local.apps

  source  = "boldlink/s3/aws"
  version = "~> 2.5.0"

  bucket                 = "${local.prefix}-${each.key}"
  sse_sse_algorithm      = "aws:kms"
  sse_bucket_key_enabled = true
  sse_kms_master_key_arn = aws_kms_key.static.arn
  versioning_status      = "Enabled"
  force_destroy          = var.force_delete

  s3_logging = {
    target_bucket = var.logging_bucket
    target_prefix = "${local.aws_logs_path}/s3accesslogs/${local.prefix}-${each.key}"
  }

  lifecycle_configuration = [{
    id                                     = "static-site"
    status                                 = "Enabled"
    prefix                                 = ""
    abort_incomplete_multipart_upload_days = 7
    noncurrent_version_expiration = {
      noncurrent_days = 30
    }
  }]

  tags = merge(local.tags, { use = "static-site", app = each.key })
}

resource "aws_s3_bucket_policy" "app_bucket" {
  for_each = local.apps

  bucket = module.app_bucket[each.key].bucket
  policy = jsonencode(yamldecode(templatefile("${local.template_dir}/bucket-policy.yaml.tftpl", {
    bucket_arn                  : module.app_bucket[each.key].arn,
    vpc_endpoint_id             : data.aws_vpc_endpoint.s3.id,
    cloudfront_distribution_arn : aws_cloudfront_distribution.endpoint.arn,
  })))
}

resource "aws_cloudwatch_log_subscription_filter" "datadog" {
  depends_on = [aws_lambda_function.oidc]
  for_each   = length(local.datadog_lambda) > 0 ? local.log_groups : toset([])

  name            = "datadog"
  log_group_name  = each.value
  filter_pattern  = ""
  destination_arn = data.aws_lambda_function.datadog["this"].arn
}
