
locals {
  lookup = {
    cloudfront: {
      name: var.alias_to.dns_name
      zone_id: "Z2FDTNDATAQYW2"
      evaluate_target_health: false
    }
  }
  
  alias = local.lookup[var.alias_to._tag]

  domain_parts = split(".", var.fqdn)
  domain_without_subdomain = slice(local.domain_parts, 1, length(local.domain_parts))
  zone_name = join(".", local.domain_without_subdomain)
}

data "aws_route53_zone" "zone" {
  name = local.zone_name
  private_zone = false
}

# resource "aws_route53_zone" "zone" {
#   name = local.zone_name 
# }

resource "aws_route53_record" "alias" {
  name = var.fqdn
  zone_id = data.aws_route53_zone.zone.zone_id
  type = "A"
  
  alias {
    name = local.alias.name
    zone_id = local.alias.zone_id
    evaluate_target_health = local.alias.evaluate_target_health
  }
}
