
variable fqdn {
  type = string
}

variable api {
  type = object({
    name = string
    fqdn = string
    path = string
    scopes = set(string)
  })
}

variable client {
  type = object({
    name = string
    fqdn = string
    scopes = set(string)
  })
}

variable dns {
  type = object({
    custom = bool
    subdomain = string
    ttl = number
  })
  default = {
    custom = true
    subdomain = "auth"
    ttl = 300
  }
}

# variable roles {

# }