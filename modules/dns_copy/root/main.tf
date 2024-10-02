
resource aws_route53_zone root {
  name = var.tldp1

  lifecycle {
    prevent_destroy = true
  }
}

data aws_ram_resource_share resource_share {
  resource_owner = "OTHER-ACCOUNTS"
  name = "subdomain_delegate"
}

data aws_ssm_parameter subdomain {
  for_each = toset(data.aws_ram_resource_share.resource_share.resource_arns)
  name = each.key
}

resource aws_route53_record subdomain_delegate {
  for_each = data.aws_ssm_parameter.subdomain

  zone_id = aws_route53_zone.root.zone_id
  name = jsondecode(each.value.value).subdomain
  type = "NS"
  ttl = var.ttl
  records = jsondecode(each.value.value).nameservers
}