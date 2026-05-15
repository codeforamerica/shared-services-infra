variable "application" {
  type        = string
  description = <<-EOT
    Name of the static application. Must match one of the included app specs.
    EOT
}

variable "domain" {
  type        = string
  description = "Root domain for static app hosting."
  default     = "dev.services.cfa.codes"
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

variable "project" {
  type        = string
  description = "Name of the static apps project."
  default     = "static-hosting"
}
