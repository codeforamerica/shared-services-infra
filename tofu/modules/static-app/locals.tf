locals {
  prefix = join("-", [var.project, var.environment, var.application_name])
}
