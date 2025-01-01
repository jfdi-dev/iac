
variable "name" {
  type     = string
  nullable = false

  validation {
    condition     = trimspace(var.name) != ""
    error_message = "Name cannot be empty"
  }
}

variable "value" {
  type     = string
  nullable = false

  validation {
    condition     = trimspace(var.value) != ""
    error_message = "Value cannot be empty"
  }
}