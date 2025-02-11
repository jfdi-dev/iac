variable "name" {
  type     = string
  nullable = false
}

variable "keys" {
  type = object({
    hash = object({
      name = string
      type = string
    })
    range = object({
      name = string
      type = string
    })
  })
  nullable = false
}
