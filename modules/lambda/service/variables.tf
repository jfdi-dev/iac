
variable "name" {
  type        = string
  nullable    = false
  description = "The name of the service which groups these lambdas."
}

variable "functions" {
  type        = list(string)
  nullable    = false
  description = "The list of functions that the service must provide."
}

variable "src" {
  type        = string
  nullable    = false
  description = "Path to the root directory of the service. Needs to follow convention guidelines."
}
