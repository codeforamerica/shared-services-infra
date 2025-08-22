module "secrets" {
  source = "github.com/codeforamerica/tofu-modules-aws-secrets?ref=2.0.0"

  project     = local.project
  environment = var.environment
  add_suffix  = false

  secrets = {
    OIDC_SETTINGS = {
      description = "OIDC credentials for static documentation hosting"
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
  source     = "github.com/codeforamerica/tofu-modules-aws-doppler?ref=1.0.0"
  depends_on = [module.secrets]

  project              = local.project
  environment          = var.environment
  kms_key_arns         = [module.secrets.kms_key_arn]
  doppler_workspace_id = "08430c37e2a2889dc220"
  tags                 = local.tags
}


resource "aws_servicecatalogappregistry_application" "docs" {
  name        = local.prefix
  description = "Static documentation hosting for Code for America."

  tags = local.tags_base
}

resource "aws_kms_key" "docs" {
  description         = "Encryption key for static documentation hosting"
  enable_key_rotation = true
  policy = jsonencode(yamldecode(templatefile("${local.template_dir}/key-policy.yaml.tftpl", {
    account_id : data.aws_caller_identity.identity.account_id,
    partition : data.aws_partition.current.partition,
    bucket_name : var.bucket_name,
    cloudfront_distribution_arn : aws_cloudfront_distribution.endpoint.arn,
  })))

  tags = resource.aws_servicecatalogappregistry_application.docs.application_tag
}

resource "aws_kms_alias" "docs" {
  name          = "alias/cfa-docummentation/${var.environment}"
  target_key_id = aws_kms_key.docs.id
}

module "bucket" {
  source  = "boldlink/s3/aws"
  version = "~> 2.5.0"

  bucket                 = var.bucket_name
  sse_sse_algorithm      = "aws:kms"
  sse_bucket_key_enabled = true
  sse_kms_master_key_arn = aws_kms_key.docs.arn
  versioning_status      = "Enabled"
  force_destroy          = var.force_delete

  bucket_policy = jsonencode(yamldecode(templatefile("${local.template_dir}/bucket-policy.yaml.tftpl", {
    bucket_arn : module.bucket.arn,
    vpc_endpoint_id : data.aws_vpc_endpoint.s3.id,
    cloudfront_distribution_arn : aws_cloudfront_distribution.endpoint.arn,
  })))

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

resource "aws_s3_object" "robots" {
  bucket        = module.bucket.bucket
  key           = "robots.txt"
  source        = "${local.file_dir}/robots.txt"
  force_destroy = var.force_delete
}

resource "aws_s3_object" "index" {
  bucket         = module.bucket.bucket
  key            = "index.html"
  content_base64 = base64encode(templatefile("${local.template_dir}/index.html.tftpl", { apps = local.apps }))
  content_type   = "text/html"
  force_destroy  = var.force_delete
}

resource "aws_cloudwatch_log_subscription_filter" "datadog" {
  depends_on = [aws_lambda_function.oidc]
  for_each   = length(local.datadog_lambda) > 0 ? local.log_groups : toset([])

  name            = "datadog"
  log_group_name  = each.value
  filter_pattern  = ""
  destination_arn = data.aws_lambda_function.datadog["this"].arn
}
