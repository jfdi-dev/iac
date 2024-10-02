

module project-context {
  source = "../project-context/reader"

  is_tooling = var.is_tooling
}

module iam-deployer-role {
  source = "../iam-deployer-role"
  
  project = module.project-context.value.project
  tooling_account = module.project-context.value.accounts.tooling
}

module dns-delegate {
  source = "../dns/delegate"

  count = var.subdomain == null ? 0 : 1

  subdomain = "${var.subdomain}.${module.project-context.value.tldp1}"
  networking_account = module.project-context.value.accounts.networking
}