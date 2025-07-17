module "docs" {
  source = "./modules/docs"

  config = try(local.raw.docs, {})
}
