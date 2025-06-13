variable "domain" {
    description = "The domain for the application."
    type        = string
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

variable "project_short" {
    description = "Short name for the project, used in resource names."
    type        = string
  default     = null
}

variable "public_subnets" {
    description = "List of public subnets for the application."
    type        = list(string)
}

variable "services" {
    description = "Services to deploy for the application."
    type        = map(any)
    default     = {}
}

variable "vpc_id" {
    description = "The VPC ID where the application will be deployed."
    type        = string
}
