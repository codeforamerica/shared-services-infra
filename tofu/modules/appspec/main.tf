module "database" {
  source = "./modules/database"

  config = try(local.raw.database, {})
}

module "docs" {
  source = "./modules/docs"

  config = try(local.raw.docs, {})
}
