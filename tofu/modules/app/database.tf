module "database" {
  source = "../database"

  project         = var.project
  environment     = var.environment
  program         = var.program
  private_subnets = var.private_subnets
  vpc_id          = var.vpc_id

  database_engine  = var.database_engine
  database_version = var.database_version
  logging_key_arn  = var.logging_key_arn
  secrets_key_arn  = module.secrets.kms_key_arn
}

resource "aws_vpc_security_group_ingress_rule" "database" {
  for_each          = module.service
  security_group_id = module.database.security_group_id

  ip_protocol                  = "tcp"
  from_port                    = module.database.port
  to_port                      = module.database.port
  referenced_security_group_id = each.value.security_group_id
}
