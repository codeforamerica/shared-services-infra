output "deploy_roles" {
  description = "The IAM roles for deploying static apps."
  value       = { for k, v in aws_iam_role.deploy : k => v.arn }
}

output "endpoint_url" {
  description = "The URL of the static apps endpoint."
  value       = aws_route53_record.endpoint["A"].fqdn
}

output "prefixes" {
  description = "Prefixes that have been configured for static apps."
  value       = keys(local.apps)
}
