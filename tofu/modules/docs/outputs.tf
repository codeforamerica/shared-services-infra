output "endpoint_url" {
  description = "The URL of the documentation endpoint."
  value       = aws_route53_record.endpoint["A"].fqdn
}

output "prefixes" {
  description = "Prefixes that have been configured for documentation."
  value       = keys(local.apps)
}
