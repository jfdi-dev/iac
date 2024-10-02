

variable project {
  type = string
}

variable ci-role {
  type = string
  default = "github-ci"
}

variable github_owner {
  type = string
  nullable = true
}

variable github_repo {
  type = string
  nullable = true
}

variable github_branch {
  type = string
  nullable = true
}
