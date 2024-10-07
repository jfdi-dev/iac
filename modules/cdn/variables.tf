
variable "fqdn" {
  type = string
  nullable = false

  validation {
    condition = length(var.fqdn) > 3
    error_message = "`fqdn` must be a valid domain"
  }
}

variable "protected" {
  type = bool
  default = true
  nullable = false
}

variable "static" {
  type = list(object({
    fqdn = string
    bucket_name = string
    path = optional(string, null)
  }))
  default = []
  nullable = true
}

variable "api" {
  type = list(object({
    fqdn = string
    path = optional(string, null)
  }))
  default = []
  nullable = true

  validation {
    condition = length(concat(var.api, var.static)) > 0
    error_message = "At least one `static` or one `api` must be specified."
  }

  validation {
    condition = length([
      for o in concat(var.api, var.static): o 
      if o.path == null 
    ]) <= 1
    # condition = length(var.api) <= 1 || length(
    #   [ 
    #     for api in var.api: api.path 
    #   ]) == length(distinct(compact([ for api in var.api: api.path ])))
    error_message = "Only one `static` or `api` can be default (ie: no `path`)."
  }

  validation {
    condition = length(concat(var.api, var.static)) - length(distinct([ for o in concat(var.api, var.static): o.path ])) <= 1
    error_message = "All paths must be unique."
  }
}

