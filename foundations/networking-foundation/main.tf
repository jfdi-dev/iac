
module project-context {
  source = "../project-context/reader"
}

module dns-root {
  source = "../dns/root"

  tldp1 = module.project-context.value.tldp1
}