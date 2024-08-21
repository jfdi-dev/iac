
locals {
  is = {
    rest: var.type == "rest"
    grpc: var.type == "grpc"
    graphql: var.type == "graphql"
    async: var.type == "async"
  }
}

module "rest" {
  count = local.is.rest ? 1 : 0
  source = "./rest-api"
}

module "grpc" {
  count = local.is.grpc ? 1 : 0
  source = "./grpc-api"
}

module "graphql" {
  count = local.is.graphql ? 1 : 0
  source = "./graphql-api"
}

module "async" {
  count = local.is.async ? 1 : 0
  source = "./async-api"
}