
data "aws_ram_resource_share" "resource_share" {
  resource_owner = var.local ? "SELF" : "OTHER-ACCOUNTS"

  name = var.name

  dynamic "filter" {
    for_each = var.tags
    content {
      name   = filter.key
      values = filter.value
    }
  }
}

data "aws_ssm_parameter" "subdomain" {
  for_each = toset(data.aws_ram_resource_share.resource_share.resource_arns)
  name     = each.key
}

locals {
  parameters = {
    for key, value in data.aws_ssm_parameter.subdomain :
    value.name => value.insecure_value
  }
}