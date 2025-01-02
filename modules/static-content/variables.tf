
variable "name" {
  type     = string
  nullable = false

  validation {
    condition     = var.name != null && trimspace(var.name) != ""
    error_message = "Input `name` is required"
  }
}
