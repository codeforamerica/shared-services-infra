module "database" {
  source   = "../database"
  for_each = var.database_engine != null ? toset(["this"]) : toset([])

  project         = var.project
  environment     = var.environment
  private_subnets = var.private_subnets
  vpc_id          = var.vpc_id
  tags            = local.tags

  database_engine  = var.database_engine
  database_version = var.database_version
  logging_key_arn  = var.logging_key_arn
  secrets_key_arn  = module.secrets.kms_key_arn
}

resource "aws_vpc_security_group_ingress_rule" "database" {
  for_each          = length(module.database) > 0 ? module.service : {}
  security_group_id = module.database["this"].security_group_id

  ip_protocol                  = "tcp"
  from_port                    = module.database["this"].port
  to_port                      = module.database["this"].port
  referenced_security_group_id = each.value.security_group_id

  tags = local.tags
}

locals {
  database_environment_variables = {
    DATABASE_HOST = try(module.database["this"].host, null)
    DATABASE_PORT = try(module.database["this"].port, null)
  }
  database_environment_secrets = {
    DATABASE_USERNAME = length(module.database) > 0 ? "${module.database["this"].secret_arn}:username" : null
    DATABASE_PASSWORD = length(module.database) > 0 ? "${module.database["this"].secret_arn}:password" : null
  }
}
