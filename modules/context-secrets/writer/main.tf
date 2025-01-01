
locals {
  context_secrets_file = "${path.root}/${var.file}"
  context              = yamldecode(file(local.context_secrets_file))
}

module "secret" {
  source = "../../secret/local"

  for_each = local.context

  name  = "context-secret-${each.key}"
  value = jsonencode(each.value)
}
