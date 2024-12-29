
locals {
  is_bronze = var.level == "bronze"
  is_silver = var.level == "silver"
  is_gold   = var.level == "gold"

  is_at_least_silver = local.is_silver || local.is_gold
}