output "enabled" {
  description = "Whether documentation is enabled for this application."
  value       = try(var.config.enabled, length(var.config) == 0 ? false : true)
}

output "private" {
  description = "Whether the documentation is private and should require authentication before viewing."
  value       = try(var.config.private, false)
}
