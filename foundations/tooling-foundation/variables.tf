
variable project {
  type = string
}

variable tldp1 {
  type = string
}

variable github_owner {
  type = string
}

variable secondary_region {
  type = string
  nullable = true
  default = null
}

variable github_repo {
  type = string
  nullable = true
  default = null
}

variable github_branch {
  type = string
  nullable = true
  default = null
}