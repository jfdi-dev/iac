
variable "project" {
  type     = string
  nullable = false
}

variable "email_template" {
  type     = string
  nullable = false

  validation {
    condition     = strcontains(var.email_template, "$${account}")
    error_message = "Email template must include the '$${account}' template parameter..."
  }
}

variable "omit" {
  type     = set(string)
  nullable = false
  default  = []
}