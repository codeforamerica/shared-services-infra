locals {
  apps               = { for k, v in var.apps : k => v if v.docs.enabled }
  build_dir          = "${path.module}/dist"
  file_dir           = "${path.module}/files"
  fqdn               = "${var.subdomain}.${var.domain}"
  lambda_dir         = "${path.module}/lambda"
  prefix             = "cfa-documentation-${var.environment}"
  protected_prefixes = [for k, v in local.apps : k if v.docs.private]
  tags_base = {
    application = local.prefix
    program     = "engineering"
    project     = "cfa-documenation"
    environment = var.environment
  }
  template_dir = "${path.module}/templates"
  tags         = merge(local.tags_base, resource.aws_servicecatalogappregistry_application.docs.application_tag)
}
