variable "domain" {
  type        = string
  description = "Root domain for static app hosting."
  default     = "dev.services.cfa.codes"
}

variable "doppler_workspace_id" {
  description = "Doppler workspace ID for syncing secrets."
  sensitive   = true
  type        = string
}

variable "environment" {
  type        = string
  description = "Deployment environment for static app resources."
  default     = "development"
}

variable "infra_project" {
  type        = string
  description = <<-EOT
    Name of the core infrastructure project whose SSM outputs this config reads.
    EOT
  default     = "shared-services"
}

variable "force_delete" {
  type        = bool
  description = <<-EOT
    Whether to allow force-deletion of non-empty S3 buckets. Should be false in
    production.
    EOT
  default     = false
}

variable "log_retention_days" {
  description = "Number of days to retain logs for static hosting resources."
  type        = number
  default     = 30
}

variable "program" {
  type        = string
  description = <<-EOT
    Name of the program the shared static hosting project belongs to.
    EOT
  default     = "engineering"
}

variable "project" {
  type        = string
  description = "Name of the shared static hosting project."
  default     = "static-hosting"
}
