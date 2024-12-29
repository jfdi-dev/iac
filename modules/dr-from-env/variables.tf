
variable "env" {
  type     = string
  nullable = false
  default  = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.env)
    error_message = "Input `env` must be one of `dev`, `test`, or `prod`"
  }
}