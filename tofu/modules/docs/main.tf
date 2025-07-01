resource "aws_servicecatalogappregistry_application" "docs" {
  name        = local.prefix
  description = "Static documentation hosting for Code for America."

  tags = local.tags_base
}

resource "aws_kms_key" "docs" {
  description = "Encryption key for static documentation hosting"
  enable_key_rotation = true
  policy = jsonencode(yamldecode(templatefile("${path.module}/templates/key-policy.yaml.tftpl", {
    account_id : data.aws_caller_identity.identity.account_id,
    partition : data.aws_partition.current.partition,
    bucket_name : var.bucket_name,
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
  force_destroy = var.force_delete

  versioning_status      = "Enabled"

  bucket_policy = jsonencode(yamldecode(templatefile("${path.module}/templates/bucket-policy.yaml.tftpl", {
    bucket_arn : module.bucket.arn,
    vpc_endpoint_id : data.aws_vpc_endpoint.s3.id,
  })))

  tags = local.tags
}

resource "aws_s3_object" "robots" {
  bucket = module.bucket.bucket
  key    = "robots.txt"
  source = "${path.module}/files/robots.txt"
  force_destroy = var.force_delete
}
