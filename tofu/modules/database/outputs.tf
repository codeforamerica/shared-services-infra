output "security_group_id" {
  description = "Security group ID for the database."
  value       = module.database_security_group.security_group_id
}

output "host" {
  description = "Host on which the database is accessible."
  value       = try(module.mssql["this"].db_instance_address, "")
}

output "port" {
  description = "Port on which the database is accessible."
  value       = try(module.mssql["this"].db_instance_port, "")
}

output "secret_arn" {
  description = "ARN of the secret containing the database credentials."
  value       = try(module.mssql["this"].db_instance_master_user_secret_arn, "")
}
