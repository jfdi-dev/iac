

module project-context {
  source = "../../modules/project-context/reader"

  is_tooling = var.is_tooling
}

module iam-deployer-role {
  source = "../../modules/iam-deployer-role"
 
  project = module.project-context.value.project
  tooling_account = module.project-context.value.accounts.tooling
}

module dns-delegate {
  source = "../../modules/dns_copy/delegate"

  count = var.subdomain == null ? 0 : 1

  subdomain = "${var.subdomain}.${module.project-context.value.tldp1}"
  networking_account = module.project-context.value.accounts.networking
}

module context-secrets {
  source = "../../modules/context-secrets/writer"

  file = var.context_secrets_file
}