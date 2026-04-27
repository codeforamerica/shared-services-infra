variable "apps" {
  description = "Static applications to host."
  type        = any
  default     = {}
}

variable "bucket_name" {
  description = "The name of the S3 bucket for static app hosting."
  type        = string
  default     = "apps.dev.cfa.codes"
}

variable "domain" {
  description = "The domain for static app hosting."
  type        = string
  default     = "dev.cfa.codes"
}

variable "environment" {
  description = "The environment for static app hosting."
  type        = string
}

variable "force_delete" {
  description = "Whether to allow resources to be deleted."
  type        = bool
  default     = false
}

variable "logging_bucket" {
  description = "The S3 bucket used for logging."
  type        = string
}

variable "subdomain" {
  description = "The subdomain for static app hosting."
  type        = string
  default     = "apps"
}

variable "vpc_id" {
  description = "The VPC where the static app hosting resources will be deployed."
  type        = string
}
