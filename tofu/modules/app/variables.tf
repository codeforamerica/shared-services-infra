variable "application_name" {
  description = "The name of the application."
  type        = string
}

variable "database_engine" {
  description = "The database engine to use for the application."
  type        = string
  default     = null
}

variable "database_version" {
  description = "The version of the database engine to use."
  type        = string
  default     = null
}

variable "domain" {
  description = "The domain for the application."
  type        = string
}

variable "environment" {
  description = "The environment for the application."
  type        = string
}

variable "internal" {
  description = "Whether this application is internal, meaning it should only be accessible to staff via an OIDC connection."
  type        = bool
  default     = true
}

variable "logging_bucket" {
  description = "The S3 bucket used for logging."
  type        = string
}

variable "logging_key_arn" {
  description = "The ARN of the KMS key used for logging."
  type        = string
}

variable "private_subnets" {
  description = "List of private subnets for the application."
  type        = list(string)
}

variable "program" {
  description = "The organizational program the application is associated with."
  type        = string
}

variable "project" {
  description = "The name of the project."
  type        = string
}

variable "project_short" {
  description = "Short name for the project, used in resource names."
  type        = string
  default     = null
}

variable "public_subnets" {
  description = "List of public subnets for the application."
  type        = list(string)
}

variable "secrets" {
  description = "Secrets to create for use by the application."
  type = map(object({
    description = string
    type        = string
    keys        = optional(list(string), [])
  }))
  default = {}
}

variable "services" {
  description = "Services to deploy for the application."
  type        = map(any)
  default     = {}
}

variable "subdomain" {
  description = "Subdomain to host the application under. This is typically only used for services that are using a shared domain, and is usually the name of the application."
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "The VPC ID where the application will be deployed."
  type        = string
}
