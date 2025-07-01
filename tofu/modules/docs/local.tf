locals {
  fqdn   = "${var.subdomain}.${var.domain}"
  prefix = "cfa-documentation-${var.environment}"
  s3_ips = [for ni in data.aws_network_interface.s3 : ni.private_ip]
  tags_base = {
    application = local.prefix
    program     = "engineering"
    project     = "cfa-documenation"
    environment = var.environment
  }
  tags = merge(local.tags_base, resource.aws_servicecatalogappregistry_application.docs.application_tag)
}
