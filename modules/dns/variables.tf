
variable "fqdn" {
  type = string
}

variable "alias_to" {
  type = object({
    _tag     = string
    dns_name = optional(string)
    zone_id  = optional(string)
  })
}