output "certificate_validation_records" {
  description = "The DNS records required to validate the ACM certificate."
  value       = module.redirect.certificate_validation_records
}

output "endpoint_url" {
  description = "The URL of the documentation endpoint."
  value       = module.docs.endpoint_url
}

output "prefixes" {
  description = "Prefixes that have been configured for documentation."
  value       = module.docs.prefixes
}

output "redirect_dns" {
  description = "DNS information for the CloudFront redirect needed to create DNS records."
  value       = module.redirect.cloudfront_dns
}
