module "database" {
  source = "./modules/database"

  config = try(local.raw.database, {})
}

module "docs" {
  source = "./modules/docs"

  config = try(local.raw.docs, {})
}

module "doppler" {
  source = "./modules/doppler"

  config = try(local.raw.doppler, {})
}

module "secrets" {
  source = "./modules/secrets"

  config = try(local.raw.secrets, {})
}
