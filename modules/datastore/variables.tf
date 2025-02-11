
variable "document" {
  type = map(object({
    keys = any
  }))
  default  = {}
  nullable = false
}

variable "relational" {
  type = map(object({
    keys = any
  }))
  default  = {}
  nullable = false
}
