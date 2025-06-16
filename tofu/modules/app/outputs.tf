output "log_groups" {
  value = local.log_groups
}

output "services" {
  description = "Deployed services for the application."
  value       = module.service
}
