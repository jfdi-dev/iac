
variable "partition" {
  type    = string
  default = "aws"
}

variable "service" {
  type     = string
  nullable = false

  validation {
    condition     = var.service != ""
    error_message = "Service cannot be null or empty"
  }
}

variable "region" {
  type     = string
  nullable = true
  default  = null
}

variable "account" {
  type     = string
  nullable = true
  default  = null
}

variable "resource_type" {
  type     = string
  nullable = true
  default  = "*"
}

variable "resource_id" {
  type     = string
  nullable = true
  default  = null
}