

variable "name" {
  type = string
  nullable = true
  default = null

  validation {
    condition = var.name != null || length(keys(var.tags)) != 0
    error_message = "Either `name` or `tags` must be specified"
  }

  validation {
    condition = (var.name == null && length(keys(var.tags)) != 0) || (var.name != null && length(keys(var.tags)) == 0)
    error_message = "`name` and `tags` are mutually exclusive"
  }
}

variable "tags" {
  type = map(list(string))
  nullable = true
  default = {}
}

variable "local" {
  type = bool
  nullable = false
  default = false
}