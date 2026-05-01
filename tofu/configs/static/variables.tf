variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket for static app hosting."
  default     = "apps.dev.services.cfa.codes"
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

variable "force_delete" {
  type        = bool
  description = "Whether to allow force-deletion of resources (e.g. non-empty S3 buckets). Should be false in production."
  default     = true
}

variable "program" {
  type        = string
  description = "Name of the program the static apps project belongs to."
  default     = "engineering"
}

variable "project" {
  type        = string
  description = "Name of the static apps project."
  default     = "static-apps"
}
