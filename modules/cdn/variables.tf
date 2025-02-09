
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

  validation {
    condition = length([
      for o in values(var.static) : o
      if o.path == null
    ]) <= 1
    error_message = "Only one `static` can be default (ie: has no `path`)."
  }

  validation {
    condition     = length(keys(var.static)) - length(distinct([for o in values(var.static) : o.path])) == 0
    error_message = "All static paths must be unique."
  }

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
      for o in values(var.api) : o
      if o.path == null
    ]) <= 1
    error_message = "Only one `api` can be default (ie: has no `path`)."
  }

  validation {
    condition     = length(keys(var.api)) - length(distinct([for o in values(var.api) : o.path])) == 0
    error_message = "All api paths must be unique."
  }
}

variable "streaming" {
  type = map(object({
    url  = string
    path = optional(string, null)
  }))
  default  = {}
  nullable = true
}

# defo need a better way of doing this, 
# but it will do for now...
variable "auth_lambda_arns" {
  type     = set(string)
  nullable = true
  default  = []
}