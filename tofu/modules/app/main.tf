module "service" {
  source = "github.com/codeforamerica/tofu-modules-aws-fargate-service?ref=1.2.1"
  for_each = var.services

  project       = var.project
  project_short = local.project_short
  environment   = var.environment
  public        = try(each.value.public, false)
  service       = each.key
  service_short = try(each.value.short_name, each.key)

  domain    = var.domain
  subdomain = try(each.value.subdomain, "www")

  vpc_id          = var.vpc_id
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  logging_key_id  = var.logging_key_arn
  container_port  = try(each.value.expose, 3000)
  create_version_parameter = true

  tags = {
    application = "${var.project}-${var.environment}"
    program = var.program
  }
}
