
variable "type" {
  type     = string
  nullable = false

  validation {
    condition     = contains([], var.type)
    error_message = "`type` must be one of 'rest', 'grpc', 'graphql', 'async'"
  }
}