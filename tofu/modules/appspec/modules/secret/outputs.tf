output "add_suffix" {
  description = "Whether to add a random suffix to the secret name."
  value       = try(var.config.add_suffix, true)
}

output "description" {
  description = "Description for the secret."
  value       = try(var.config.description, null)
}

output "name" {
  description = "Name for the secret."
  value       = try(var.config.name, var.key)
}

output "keys" {
  description = "Keys to pre-populate for JSON secrets."
  value       = try(var.config.type, "string") == "json" ? try(var.config.keys, []) : []
}

output "type" {
  description = "The value type. Options are: 'string' (default), 'json'."
  value       = try(var.config.type, "string")
}
