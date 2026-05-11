variable "environment" {
  type        = string
  description = "Deployment environment for the documentation resources."
  default     = "development"
}

variable "infra_project" {
  type        = string
  description = <<-EOT
    Name of the core infrastructure project whose SSM outputs this config reads.
    EOT
  default     = "shared-services"
}

variable "program" {
  type        = string
  description = "Name of the program the documentation project belongs to."
  default     = "engineering"
}

variable "project" {
  type        = string
  description = "Name of the documentation project."
  default     = "cfa-documentation"
}
