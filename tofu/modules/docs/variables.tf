variable "bucket_name" {
  description = "The name of the S3 bucket for documentation hosting."
  type        = string
  default     = "docs.dev.cfa.codes"
}

variable "domain" {
  description = "The domain for the documentation hosting."
  type        = string
  default     = "dev.cfa.codes"
}

variable "environment" {
  description = "The environment for documentation hosting."
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

variable "prefixes" {
  description = "A list of prefixes to create access policies for."
  type        = set(string)
  default     = []
}

variable "subdomain" {
  description = "The subdomain for the documentation hosting."
  type        = string
  default     = "docs"
}

variable "vpc_id" {
  description = "The VPC where the documentation hosting resources will be deployed."
  type        = string
}
