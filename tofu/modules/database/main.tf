resource "aws_kms_key" "database" {
  description             = "Database encryption key for ${var.project} ${var.environment}"
  deletion_window_in_days = local.production ? 30 : 7
  enable_key_rotation     = true
  policy = jsonencode(yamldecode(templatefile("${path.module}/templates/key-policy.yaml.tftpl", {
    account_id : data.aws_caller_identity.identity.account_id,
    partition : data.aws_partition.current.partition,
    region : data.aws_region.current.name,
  })))

  tags = local.tags
}

resource "aws_kms_alias" "database" {
  name          = "alias/${var.project}/${var.environment}/database"
  target_key_id = aws_kms_key.database.id
}

module "mssql" {
  source   = "terraform-aws-modules/rds/aws"
  version  = ">= 6.12"
  for_each = var.database_engine == "mssql" ? toset(["this"]) : toset([])

  identifier                             = local.prefix
  instance_use_identifier_prefix         = true
  engine                                 = local.database_engine
  engine_version                         = data.aws_rds_engine_version.this.version
  auto_minor_version_upgrade             = true
  apply_immediately                      = !local.production
  subnet_ids                             = var.private_subnets
  create_db_subnet_group                 = true
  create_db_option_group                 = false
  family                                 = data.aws_rds_engine_version.this.parameter_group_family
  instance_class                         = "db.t3.small"
  allocated_storage                      = 20
  max_allocated_storage                  = 100
  username                               = "root"
  storage_type                           = "gp3"
  kms_key_id                             = aws_kms_key.database.arn
  master_user_secret_kms_key_id          = var.secrets_key_arn
  performance_insights_kms_key_id        = var.logging_key_arn
  cloudwatch_log_group_kms_key_id        = var.logging_key_arn
  cloudwatch_log_group_retention_in_days = local.production ? 31 : 7
  create_cloudwatch_log_group            = true
  create_monitoring_role                 = true
  enabled_cloudwatch_logs_exports        = data.aws_rds_engine_version.this.exportable_log_types
  vpc_security_group_ids                 = [module.database_security_group.security_group_id]

  allow_major_version_upgrade = !local.production

  tags = local.tags
}

# Create an empty security group for the database. To avoid a circular
# dependency between the database and the services, we create the security group
# here and then add the ingress rules in a separate resource.
module "database_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3"

  name   = "${local.prefix}-database"
  vpc_id = var.vpc_id

  tags = local.tags
}
