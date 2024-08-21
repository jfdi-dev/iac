
variable "document" {
  type = object({
  })
  default = null
  nullable = true
}

variable "rdbms" {
  type = object({
    y = number
  })
  default = null
  nullable = true

  validation {
    condition = (var.document != null || var.rdbms != null) && !(var.document != null && var.rdbms != null)
    error_message = "(Only) one of `document` or `rdbms` must be set."
  }
}
