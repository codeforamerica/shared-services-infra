output "database" {
  description = "The database configuration for the application."
  value       = module.database
}

output "docs" {
  description = "Configuration for documentation."
  value       = module.docs
}

output "domain" {
  description = "The DNS domain for the app."
  value       = try(local.raw.domain, null)
}

output "enabled" {
  description = "Whether the application is enabled."
  value       = try(local.raw.enabled, true)
}

output "internal" {
  description = "Whether this application is internal, meaning it should only be accessible to staff via an OIDC connection."
  value       = try(local.raw.internal, true)
}

output "name" {
  description = "The name of the app."
  value       = local.raw.title
}

output "program" {
  description = "The organizational program the application is associated with."
  value       = local.raw.program
}

output "project" {
  description = "The name of the project."
  value       = local.raw.name
}

output "project_short" {
  description = "Short name for the project, used in resource names with space limitations."
  value       = try(local.raw.name_short, local.raw.name)
}

output "secrets" {
  description = "Secrets to create for use by the application."
  value       = module.secrets.secrets
}

output "services" {
  description = "Services to deploy for the application."
  value       = try(local.raw.services, {})
}

output "subdomain" {
  description = "Subdomain to host the application under. This is typically only used for services that are using a shared domain, and is usually the name of the application."
  value       = try(local.raw.subdomain, null)
}

output "title" {
  description = "The title of the app."
  value       = try(local.raw.title, local.raw.name)
}

output "raw_spec" {
  description = "The full specification for the app."
  value       = local.raw
}
