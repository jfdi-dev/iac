
module "project-context" {
  source = "../../modules/project-context/reader"
}

module "dns-root" {
  source = "../../modules/dns_copy/root"

  tldp1 = module.project-context.value.tldp1
}