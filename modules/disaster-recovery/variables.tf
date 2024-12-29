
variable "level" {
  type     = string
  nullable = false
  default  = "bronze"

  validation {
    condition     = contains(["bronze", "silver", "gold"], var.level)
    error_message = "Input `level` must be one of `bronze`, `silver`, or `gold`"
  }
}