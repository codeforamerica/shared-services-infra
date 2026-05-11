locals {
  prefix = join("-", [var.project, var.environment, var.application])

  tags = merge(local.tags_base, aws_servicecatalogappregistry_application.application.application_tag)
  tags_base = {
    awsApplication = module.inputs.values["application/tag"]
    program        = module.appspec.program
  }
}
