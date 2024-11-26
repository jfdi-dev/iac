
variable "name" {
  type = string
}

variable "edge_lambda" {
  type = bool
  default = false
  nullable = false
}

variable apigw_lambda {
  type = bool
  default = false
  nullable = false
}

variable "src" {
  type = string
  default = "./src/"
  nullable = false
}

variable "handler" {
  type = string
  default = "index.handler"
  nullable = false
}

variable "env_vars" {
  type = map(string)
  nullable = false
  default = {}

  validation {
    condition = length(var.env_vars) == 0 || !var.edge_lambda
    error_message = "Edge lambdas cannot have environment variables."
  }
}


variable policies {
  type = object({
    custom = optional(
      map(
        list(
          object({
            effect = string
            actions = set(string)
            resources = set(string)
          })
        )
      )
    )
    named = optional(set(string))
    managed = optional(set(string))
  })
  default = {
    custom = {}
    named = []
    managed = []
  }
}

variable "settings" {
  type = object({
    runtime = object({
      name = optional(string)
      memory_size = optional(number)
      timeout = optional(number)
    })
    concurrency = object({
      reserved = optional(number)
      provisioned = optional(number)
    })
  })
  default = {
    runtime = {
      name = "nodejs20.x"
      memory_size = 128
      timeout = 30
    }
    concurrency = {
      reserved = 1
      provisioned = 0
    }
  }
}