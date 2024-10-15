
module manifest {
  source = "../../artifact-manifest"
}

module context-secrets {
  source = "../../context-secrets/reader"

  context_secrets = module.manifest.value.secrets
}