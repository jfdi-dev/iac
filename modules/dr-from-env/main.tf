
locals {
  level_from_env = tomap({
    development = "bronze"
    dev = "bronze"
    staging = "silver"
    test = "silver"
    production = "gold"
    prod = "gold"
  })
  level = local.level_from_env[var.env]
}