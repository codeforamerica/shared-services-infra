variable "application" {
  type        = string
  description = "Name of the hosted application. Must match one of the included app specs."
}

variable "environment" {
  type        = string
  description = "Deployment environment for the hosted application."
  default     = "development"
}

variable "project" {
  type        = string
  description = "Name of the shared hosting project."
  default     = "shared-services"
}
