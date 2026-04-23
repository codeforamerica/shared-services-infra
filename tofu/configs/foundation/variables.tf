variable "environment" {
  type        = string
  description = "Deployment environment for the shared hosting resources."
  default     = "development"
}

variable "program" {
  type        = string
  description = "Name of the program the shared hosting project belongs to."
  default     = "engineering"
}

variable "project" {
  type        = string
  description = "Name of the shared services project."
  default     = "shared-services"
}
