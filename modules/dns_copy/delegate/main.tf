
resource aws_route53_zone subdomain {
  name = var.subdomain
}

resource aws_ssm_parameter subdomain {
  tier = "Advanced"
  name = var.subdomain
  type = "StringList"
  value = jsonencode({
    subdomain = var.subdomain
    nameservers = aws_route53_zone.subdomain.name_servers
  })
}

resource aws_ram_resource_share subdomain {
  name = "subdomain_delegate"
  allow_external_principals = false
}

resource aws_ram_resource_association subdomain {
  resource_arn = aws_ssm_parameter.subdomain.arn
  resource_share_arn = aws_ram_resource_share.subdomain.arn
}

resource aws_ram_principal_association subdomain {
  resource_share_arn = aws_ram_resource_share.subdomain.arn
  principal = var.networking_account
}