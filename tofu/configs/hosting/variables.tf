variable "application" {
  type        = string
  description = "Name of the hosted application. Must match one of the included app specs."
}

variable "environment" {
  type        = string
  description = "Deployment environment for the hosted application."
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
  description = "Name of the shared hosting project."
  default     = "shared-services"
}
