
variable "path" {
  type    = string
  default = "manifest.yml"

  validation {
    condition     = fileexists("${path.root}/${var.path}")
    error_message = "File '${var.path}' does not exist in '${path.root}'"
  }
}

variable "_fail_on_error" {
  type    = bool
  default = true
}
