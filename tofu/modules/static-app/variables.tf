variable "application_name" {
  description = "Name of the static application (matches the spec name field)."
  type        = string
}

variable "bucket_arn" {
  description = "ARN of the shared static app content S3 bucket."
  type        = string
}

variable "domain" {
  description = "Root domain for static application hosting."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "program" {
  description = "Organizational program this app belongs to."
  type        = string
  default     = "engineering"
}

variable "project" {
  description = "Project name used in resource naming and tagging."
  type        = string
  default     = "static-apps"
}

variable "repo" {
  description = <<-EOT
    GitHub repository (org/name) that deploys this application. Used to scope
    the OIDC trust policy.
    EOT
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}
