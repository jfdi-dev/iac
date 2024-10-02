
variable project {
  type = string
}

variable tooling_account {
  type = string
}

variable artifact_name {
  type = string
}

variable attached_policies {
  type = map(list(object({ 
    effect = optional(string)
    actions = optional(set(string))
    resources = optional(set(string))
  })))
  default = {}
}

variable named_policies {
  type = map(string)
  default = {}
}

variable managed_policies {
  type = map(string)
  default = {}
}