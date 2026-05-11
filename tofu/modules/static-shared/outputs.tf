output "bucket_arn" {
  description = "ARN of the shared static app content S3 bucket."
  value       = module.bucket.arn
}

output "bucket_name" {
  description = "Name of the shared static app content S3 bucket."
  value       = module.bucket.bucket
}

output "distribution_arn" {
  description = "ARN of the shared CloudFront distribution."
  value       = aws_cloudfront_distribution.endpoint.arn
}

output "distribution_domain" {
  description = "CloudFront distribution domain name."
  value       = aws_cloudfront_distribution.endpoint.domain_name
}

output "distribution_id" {
  description = <<-EOT
    CloudFront distribution ID. Use as CLOUDFRONT_DISTRIBUTION_ID in deploy
    configuration.
    EOT
  value       = aws_cloudfront_distribution.endpoint.id
}

output "kms_key_arn" {
  description = "ARN of the KMS key used to encrypt static app content."
  value       = aws_kms_key.static.arn
}
