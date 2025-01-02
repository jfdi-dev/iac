
resource "aws_route53_zone" "root" {
  name = var.tldp1

  lifecycle {
    prevent_destroy = true
  }
}

module "parameter" {
  source = "../../parameter/reader"

  tags = {
    context = ["subdomains"]
  }
}

resource "aws_route53_record" "subdomain_delegate" {
  for_each = module.parameter.value

  zone_id = aws_route53_zone.root.zone_id
  name    = jsondecode(each.value).subdomain
  type    = "NS"
  ttl     = var.ttl
  records = jsondecode(each.value).nameservers
}