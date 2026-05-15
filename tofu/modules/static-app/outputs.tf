output "bucket_prefix" {
  description = <<-EOT
    Prefix for the S3 bucket used to store the static application content.
    EOT
  value       = var.application_name
}

output "deploy_role_arn" {
  description = <<-EOT
    ARN of the role for deploying this application via GitHub Actions.
    EOT
  value       = aws_iam_role.deploy.arn
}

output "endpoint_url" {
  description = "URL for this static app."
  value       = "https://${var.application_name}.apps.${var.domain}"
}
