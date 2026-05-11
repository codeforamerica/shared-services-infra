variable "domain" {
  description = <<-EOT
    Root domain for static app hosting (e.g. `"dev.services.cfa.codes"`). Apps
    are served from `*.apps.{domain}`.
    EOT
  type        = string
}

variable "doppler_workspace_id" {
  description = "Doppler workspace ID for syncing secrets."
  sensitive   = true
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "force_delete" {
  description = <<-EOT
    Whether to allow force-deletion of non-empty S3 buckets. Should be `false`
    in production.
    EOT
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Number of days to retain logs for static hosting resources."
  type        = number
  default     = 30
}

variable "logging_bucket" {
  description = "S3 bucket used for access logs."
  type        = string
}

variable "logging_key_arn" {
  description = "ARN of the KMS key used to encrypt logs."
  type        = string
}

variable "program" {
  description = "Organizational program this project belongs to."
  type        = string
  default     = "engineering"
}

variable "project" {
  description = "Project name used in resource naming and tagging."
  type        = string
  default     = "static-apps"
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC where static app hosting resources are deployed."
  type        = string
}
