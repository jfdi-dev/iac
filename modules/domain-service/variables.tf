
variable "fqdn" {
  type = string
}

variable "protected" {
  type = bool
  nullable = false
  default = true
}

variable "disaster_recovery_level" {
  type = string
  nullable = false
}

variable env {
  type = string
}

variable "statics" {
  type = map(object({
    path = string
    src = string
    scopes = set(string)
  }))
  nullable = true
  default = {}
}

variable "apis" {
  type = map(object({
    path = string
    src = string
    spec = string
    scopes = set(string)
  }))
  nullable = true
  default = {}  
}

variable "datastores" {
  type = map(object({
    type = string
    src = string
  }))
  nullable = true
  default = {}
}