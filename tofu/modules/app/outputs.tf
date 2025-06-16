output "log_groups" {
  description = "Log groups created for the application, used for log ingestion."
  value       = local.log_groups
}

output "services" {
  description = "Deployed services for the application."
  value       = module.service
}
