
variable "env" {
  type     = string
  nullable = false
  default  = "development"

  validation {
    condition     = contains(["development", "dev", "test", "staging", "production", "prod"], var.env)
    error_message = "Input `env` must be one of `dev`, `development`, `test`, `staging`, `production`, or `prod`"
  }
}