
variable "identity" {
  type = string
}

variable "policies" {
  type = object({
    custom = optional(
      map(
        list(
          object({
            effect    = string
            actions   = set(string)
            resources = set(string)
          })
        )
      )
    )
    named   = optional(set(string))
    managed = optional(set(string))
    service = optional(set(string))
  })
  default = {
    custom  = {}
    named   = []
    managed = []
  }
}

variable "account" {
  type     = string
  nullable = true
  default  = null
}