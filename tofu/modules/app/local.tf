locals {
  database_engine = var.database_engine == "mssql" ? "sqlserver-web" : var.database_engine
  domain_prefix = "${var.subdomain == null ? "" : ".${var.subdomain}"}${local.production ? "" : ".${var.environment}"}"
  prefix          = "${var.project}-${var.environment}"
  production      = var.environment == "production"
  project_short   = var.project_short != null ? var.project_short : var.project
  tags = {
    application = "${var.project}-${var.environment}"
    program     = var.program
    project     = var.project
    environment = var.environment
  }
}
