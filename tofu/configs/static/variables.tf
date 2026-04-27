variable "environment" {
  type        = string
  description = "Deployment environment for static app resources."
  default     = "development"
}

variable "program" {
  type        = string
  description = "Name of the program the static apps project belongs to."
  default     = "engineering"
}

variable "project" {
  type        = string
  description = "Name of the static apps project."
  default     = "cfa-static-apps"
}
