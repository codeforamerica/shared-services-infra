variable "config" {
  description = "Secret configuration."
  type        = any
  default     = {}
}

variable "key" {
  description = "Key used to identify the secret in the config map."
  type        = string
}
