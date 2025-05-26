
variable "project" {
  type = string
}

variable "tooling_account" {
  type = string
}

variable "artifact_name" {
  type = string
}

variable "namespace" {
  type = bool
  default = false
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
    service = []
  }
}
