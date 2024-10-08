
locals {
  policies = {
    custom = coalesce(var.policies.custom, {})
    named = coalesce(var.policies.named, [])
    managed = coalesce(var.policies.managed, [])
    service = coalesce(var.policies.service, [])
  }
}

module managed_arns {
  source = "../arn"
  for_each = local.policies.managed

  service = "iam"
  account = ""
  region = ""
  resource_type = "policy"
  resource_id = each.value
}

module service_arns {
  source = "../arn"
  for_each = local.policies.managed

  service = "iam"
  region = ""
  account = ""
  resource_type = "policy"
  resource_id = "service-role/${each.value}"
}

module named_arns {
  source = "../arn"
  for_each = local.policies.managed

  service = "iam"
  region = ""
  resource_type = "policy"
  resource_id = "${each.value}"
}

data aws_iam_policy_document custom_policies {
  for_each = local.policies.custom
  dynamic statement {
    for_each = each.value
    content {
      effect = statement.value["effect"]
      actions = statement.value["actions"]
      resources = statement.value["resources"]
    }
  }
}

resource aws_iam_policy custom_policies {
  for_each = { for idx, policy in data.aws_iam_policy_document.custom_policies: idx => policy }

  name = each.key
  policy = each.value.json
}

locals {
  managed_policy_arns = module.managed_arns[*].value
  named_policy_arns = module.named_arns[*].value
  service_policy_arns = module.service_arns[*].value
  custom_policy_arns = aws_iam_policy.custom_policies[*].arn
  all_policy_arns = concat(
    local.custom_policy_arns,
    local.named_policy_arns,
    local.managed_policy_arns, 
    local.service_policy_arns
  )
}

resource aws_iam_role_policy_attachment policy_attachments {
  for_each = local.all_policy_arns

  role = var.identity
  policy_arn = each.value.arn
}

