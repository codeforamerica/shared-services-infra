variable "environment" {
  type        = string
  description = "Deployment environment for the shared hosting resources."
  default     = "development"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets."
}

variable "program" {
  type        = string
  description = "Name of the program the shared hosting project belongs to."
  default     = "engineering"
}

variable "project" {
  type        = string
  description = "Name of the shared hosting project."
  default     = "shared-services"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
}
