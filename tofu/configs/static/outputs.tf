output "deploy_roles" {
  description = "IAM roles for deploying each static app."
  value       = module.static.deploy_roles
}

output "endpoint_url" {
  description = "The URL of the static apps endpoint."
  value       = module.static.endpoint_url
}

output "prefixes" {
  description = "Prefixes that have been configured for static apps."
  value       = module.static.prefixes
}
