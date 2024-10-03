
locals {
  level_from_env = tomap({
    dev = "bronze"
    test = "silver"
    prod = "gold"
  })
  level = local.level_from_env[var.env]
}