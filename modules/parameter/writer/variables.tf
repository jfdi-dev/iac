
variable "name" {
  type     = string
  nullable = false
}

variable "value" {
  type     = string
  nullable = false
}

variable "shared_with" {
  type     = set(string)
  nullable = false
}

variable "tags" {
  type     = map(string)
  nullable = true
  default  = {}
}