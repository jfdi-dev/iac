
variable "fqdn" {
  type     = string
  nullable = false

  validation {
    condition     = length(var.fqdn) > 3
    error_message = "`fqdn` must be a valid domain"
  }
}

variable "static" {
  type = map(object({
    fqdn        = string
    bucket_name = string
    path        = optional(string, null)
  }))
  default  = {}
  nullable = true
}

variable "api" {
  type = map(object({
    fqdn = string
    path = optional(string, null)
  }))
  default  = {}
  nullable = true

  validation {
    condition     = length(concat(keys(var.api), keys(var.static))) > 0
    error_message = "At least one `static` or one `api` must be specified."
  }

  validation {
    condition = length([
      for o in concat(values(var.api), values(var.static)) : o
      if o.path == null
    ]) <= 1
    error_message = "Only one `static` or `api` can be default (ie: has no `path`)."
  }

  validation {
    condition     = length(concat(keys(var.api), keys(var.static))) - length(distinct([for o in concat(values(var.api), values(var.static)) : o.path])) == 0
    error_message = "All paths must be unique."
  }
}

# defo need a better way of doing this, 
# but it will do for now...
variable "auth_lambda_arns" {
  type     = set(string)
  nullable = true
  default  = []
}