
variable is_tooling {
  type = bool
  default = false
}

variable subdomain {
  type = string
  nullable = true
  default = null
}

variable context_secrets_file {
  type = string
}