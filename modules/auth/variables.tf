
variable "fqdn" {
  type = string
}

variable "api" {
  type = object({
    name   = string
    fqdn   = string
    path   = string
    scopes = set(string)
  })
}

variable "client" {
  type = object({
    name       = string
    fqdn       = string
    scopes     = set(string)
    short_name = string
  })
}

variable "dns" {
  type = object({
    custom    = bool
    subdomain = string
    ttl       = number
  })
  default = {
    custom    = true
    subdomain = "auth"
    ttl       = 300
  }
}

variable "connections" {
  type    = set(string)
  default = ["database"]
}

variable "disable_signup" {
  type    = bool
  default = false
}

variable "roles" {
  type    = map(set(string))
  default = {}
}

# variable roles {

# }