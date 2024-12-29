
variable "name" {
  type     = string
  nullable = false

  validation {
    condition     = var.name != null && trimspace(var.name) != ""
    error_message = "Input `name` is required"
  }
}

variable "dr" {
  type = object({
    is_at_least_silver = bool
  })
  nullable = false
}
