
module "project-context" {
  source = "../../modules/project-context/reader"
}

module "dns-root" {
  source = "../../modules/dns/root"

  tldp1 = module.project-context.value.tldp1
}