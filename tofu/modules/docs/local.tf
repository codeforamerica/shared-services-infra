locals {
  fqdn   = "${var.subdomain}.${var.domain}"
  prefix = "cfa-documentation-${var.environment}"
  tags_base = {
    application = local.prefix
    program     = "engineering"
    project     = "cfa-documenation"
    environment = var.environment
  }
  tags = merge(local.tags_base, resource.aws_servicecatalogappregistry_application.docs.application_tag)
}
