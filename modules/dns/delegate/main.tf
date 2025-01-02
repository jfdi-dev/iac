module project-context {
  source = "../../project-context/reader"
}

resource "aws_route53_zone" "subdomain" {
  name = var.subdomain
}

module "parameter" {
  source = "../../parameter/writer"

  name = var.subdomain
  value = jsonencode({
    subdomain   = var.subdomain
    nameservers = aws_route53_zone.subdomain.name_servers
  })
  shared_with = [module.project-context.value.accounts.networking]

  tags = {
    context = "subdomains"
  }
}
