output "bucket_prefix" {
  description = <<-EOT
    Prefix for the S3 bucket used to store the static application content.
    EOT
  value       = module.app[var.application].bucket_prefix
}

output "deploy_role_arn" {
  description = <<-EOT
    ARN of the role for deploying this application via GitHub Actions.
    EOT
  value       = module.app[var.application].deploy_role_arn
}

output "endpoint_url" {
  description = "URL for the static application."
  value       = module.app[var.application].endpoint_url
}
