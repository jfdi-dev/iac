
# locals {
#   is = {
#     rest : var.type == "rest"
#     grpc : var.type == "grpc"
#     graphql : var.type == "graphql"
#     async : var.type == "async"
#   }
# }

# module "rest" {
#   count  = local.is.rest ? 1 : 0
#   source = "./rest"
# }

# module "grpc" {
#   count  = local.is.grpc ? 1 : 0
#   source = "./grpc"
# }

# module "graphql" {
#   count  = local.is.graphql ? 1 : 0
#   source = "./graphql"
# }

# module "async" {
#   count  = local.is.async ? 1 : 0
#   source = "./async"
# }