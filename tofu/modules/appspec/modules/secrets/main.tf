module "secret" {
  source = "../secret"

  for_each = var.config

  config = each.value
  key    = each.key
}
