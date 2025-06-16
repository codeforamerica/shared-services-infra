module "secrets" {
  source = "github.com/codeforamerica/tofu-modules-aws-secrets?ref=1.0.0"

  project     = var.project
  environment = var.environment
}

module "service" {
  source   = "github.com/codeforamerica/tofu-modules-aws-fargate-service?ref=1.3.0"
  for_each = var.services

  project            = var.project
  project_short      = local.project_short
  environment        = var.environment
  public             = try(each.value.public, false)
  service            = each.key
  service_short      = try(each.value.short_name, each.key)
  desired_containers = try(each.value.desired_containers, local.production ? 2 : 1)
  health_check_path  = try(each.value.health_check_path, "/health")

  domain    = var.domain
  subdomain = "${try(each.value.subdomain, "www")}${local.domain_prefix}"

  vpc_id                   = var.vpc_id
  private_subnets          = var.private_subnets
  public_subnets           = var.public_subnets
  logging_key_id           = var.logging_key_arn
  container_port           = try(each.value.expose, 3000)
  create_version_parameter = true

  environment_variables = {
    DATABASE_HOST = module.mssql.db_instance_endpoint
  }

  environment_secrets = {
    DATABASE_USERNAME = "${module.mssql.db_instance_master_user_secret_arn}:username"
    DATABASE_PASSWORD = "${module.mssql.db_instance_master_user_secret_arn}:password"
  }

  tags = local.tags
}

module "mssql" {
  source  = "terraform-aws-modules/rds/aws"
  version = ">= 6.12"

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
  master_user_secret_kms_key_id          = module.secrets.kms_key_arn
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

resource "aws_vpc_security_group_ingress_rule" "database" {
  for_each          = module.service
  security_group_id = module.database_security_group.security_group_id

  ip_protocol                  = "tcp"
  from_port                    = module.mssql.db_instance_port
  to_port                      = module.mssql.db_instance_port
  referenced_security_group_id = each.value.security_group_id
}

resource "aws_cloudwatch_log_subscription_filter" "datadog" {
  depends_on = [module.service]
  for_each   = length(local.datadog_lambda) > 0 ? local.log_groups : toset([])

  name            = "datadog"
  log_group_name  = each.value
  filter_pattern  = ""
  destination_arn = data.aws_lambda_function.datadog["this"].arn
}
