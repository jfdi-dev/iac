
variable "path" {
  type = string
}

variable "defaults" {
  type = object({
    runtime = object({
      name = string
      timeout = number
      memory_size = number
    })
    concurrency = object({
      reserved = number
      provisioned = number
    })
    iam_role_statements = list(object({
      effect = string
      actions = list(string)
      resources = list(string)
    }))
  })
  default = {
    runtime = {
      name = "nodejs20.x"
      timeout = 5
      memory_size = 128
    }
    concurrency = {
      provisioned = 0
      reserved = -1
    }
    iam_role_statements = [ ]
  }
}