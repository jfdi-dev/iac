
variable "fqdn" {
  type = string
}

variable "protected" {
  type     = bool
  nullable = false
  default  = true
}

variable "disaster_recovery_level" {
  type     = string
  nullable = false
}

variable "env" {
  type = string
}

variable "statics" {
  type = map(object({
    path       = optional(string, null)
    src        = string
    scopes     = set(string)
    short_name = string
  }))
  nullable = true
  default  = {}
}

variable "apis" {
  type = map(object({
    path   = optional(string, null)
    src    = string
    spec   = string
    scopes = set(string)
  }))
  nullable = true
  default  = {}
}

variable "streaming" {
  type = map(object({
    path = optional(string, null)
    src  = string
  }))
  nullable = true
  default  = {}
}

variable "datastores" {
  type = object({
    document   = optional(map(any))
    relational = optional(map(any))
  })
  nullable = true
  default  = {}
}

variable "auth" {
  type = object({
    connections    = set(string)
    disable_signup = bool
    roles          = optional(map(set(string)))
  })
  nullable = true
  default = {
    connections    = []
    disable_signup = false
    roles          = {}
  }
}
