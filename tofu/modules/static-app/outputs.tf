output "deploy_roles" {
  description = "The IAM roles for deploying static apps."
  value       = { for k, v in aws_iam_role.deploy : k => v.arn }
}

output "endpoint_url" {
  description = "The URL of the static apps endpoint."
  value       = aws_route53_record.endpoint["A"].fqdn
}

output "bucket_names" {
  description = "Per-app S3 bucket names, indexed by app name. Use as STATIC_BUCKET in deploy configuration."
  value       = { for k, v in module.app_bucket : k => v.bucket }
}

output "prefixes" {
  description = "URL path prefixes configured for static apps. Use as STATIC_PREFIX for CloudFront cache invalidation."
  value       = keys(local.apps)
}
