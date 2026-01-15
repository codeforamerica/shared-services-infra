output "deploy_roles" {
  description = "The IAM roles for deploying the documentation."
  value       = { for k, v in aws_iam_role.deploy : k => v.arn }
}

output "endpoint_url" {
  description = "The URL of the documentation endpoint."
  value       = aws_route53_record.endpoint["A"].fqdn
}

output "prefixes" {
  description = "Prefixes that have been configured for documentation."
  value       = keys(local.apps)
}
