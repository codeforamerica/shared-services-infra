output "bucket_arn" {
  description = "ARN of the shared static app content S3 bucket."
  value       = module.static.bucket_arn
}

output "bucket_name" {
  description = <<-EOT
    Name of the shared static app content S3 bucket. Use as STATIC_BUCKET in
    deploy configuration.
    EOT
  value       = module.static.bucket_name
}

output "distribution_id" {
  description = <<-EOT
    CloudFront distribution ID. Use as CLOUDFRONT_DISTRIBUTION_ID in deploy
    configuration.
    EOT
  value       = module.static.distribution_id
}

output "endpoint_url" {
  description = "Base URL for static app hosting (apps.{domain})."
  value       = "https://${module.static.distribution_domain}"
}
