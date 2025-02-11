
variable "document" {
  type = map(object({
  }))
  default  = {}
  nullable = false
}

variable "relational" {
  type     = map(object({}))
  default  = {}
  nullable = false
}
