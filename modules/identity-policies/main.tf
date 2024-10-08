
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
  for_each = local.policies.service

  service = "iam"
  region = ""
  account = ""
  resource_type = "policy"
  resource_id = "service-role/${each.value}"
}

module named_arns {
  source = "../arn"
  for_each = local.policies.named

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
  for_each = data.aws_iam_policy_document.custom_policies

  name = each.key
  policy = each.value.json
}

resource aws_iam_role_policy_attachment managed_policy_attachments {
  for_each = module.managed_arns

  role = var.identity
  policy_arn = each.value.value
}

resource aws_iam_role_policy_attachment named_policy_attachments {
  for_each = module.named_arns

  role = var.identity
  policy_arn = each.value.value
}

resource aws_iam_role_policy_attachment service_policy_attachments {
  for_each = module.service_arns

  role = var.identity
  policy_arn = each.value.value
}

resource aws_iam_role_policy_attachment custom_policy_attachments {
  for_each = aws_iam_policy.custom_policies

  role = var.identity
  policy_arn = each.value.arn
}
