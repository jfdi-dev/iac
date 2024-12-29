
variable "path" {
  type = string
}

variable "defaults" {
  type = object({
    environment = map(string)
    runtime = object({
      name        = string
      timeout     = number
      memory_size = number
    })
    concurrency = object({
      reserved    = number
      provisioned = number
    })
    policies = object({
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
  })
  default = {
    environment = {
    }
    runtime = {
      name        = "nodejs20.x"
      timeout     = 5
      memory_size = 128
    }
    concurrency = {
      provisioned = 0
      reserved    = -1
    }
    policies = {
      custom  = {}
      named   = []
      managed = []
      service = []
    }
  }
}