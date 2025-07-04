locals {
  database_engine = var.database_engine == "mssql" ? "sqlserver-web" : var.database_engine
  prefix          = "${var.project}-${var.environment}"
  production      = var.environment == "production"
}
