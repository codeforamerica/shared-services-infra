output "project" {
  description = "Doppler project name."
  value       = try(var.config.project, null)
}
