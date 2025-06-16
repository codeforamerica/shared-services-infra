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

variable "environment" {
  description = "The environment for the application."
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
  description = "The program the application is associated with."
  type        = string
}

variable "project" {
  description = "The name of the project."
  type        = string
}

variable "secrets_key_arn" {
  description = "The ARN of the KMS key used for secrets."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the application will be deployed."
  type        = string
}
