data "aws_caller_identity" "identity" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_rds_engine_version" "this" {
  engine  = local.database_engine
  version = var.database_version
  latest  = true
}
