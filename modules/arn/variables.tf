
variable partition {
  type = string
  default = "aws"
}

variable service {
  type = string
  nullable = false
}

variable region {
  type = string
  nullable = true
  default = null
}

variable account {
  type = string
  nullable = true
  default = null
}

variable resource_type {
  type = string
  nullable = true
  default = "*"
}

variable resource_id {
  type = string
  nullable = true
  default = null
}