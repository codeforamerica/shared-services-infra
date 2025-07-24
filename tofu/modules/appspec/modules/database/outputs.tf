output "type" {
  description = "The type of database engine to use."
  value       = try(var.config.type, null)
}

output "version" {
  description = "A specific version of the database engine to use."
  value       = try(var.config.version, null)
}
