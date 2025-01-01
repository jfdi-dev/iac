
#
# `Role Policies`
# ===================
#
# Attaches a bunch of policies to a given role.
#
# Policies can be named, managed, service, or custom (these policies are created).
#

locals {
  policies = {
    custom  = coalesce(var.policies.custom, {})
    named   = coalesce(var.policies.named, [])
    managed = coalesce(var.policies.managed, [])
    service = coalesce(var.policies.service, [])
  }

  service_resource_ids = [for service in local.policies.service : "service-role/${service}"]
}

module "policy_arns" {
  source   = "../arn"
  for_each = concat(local.policies.managed, local.service_resource_ids, local.policies.named)

  service       = "iam"
  account       = "aws"
  region        = ""
  resource_type = "policy"
  resource_id   = each.value
}

data "aws_iam_policy_document" "custom_policies" {
  for_each = local.policies.custom
  dynamic "statement" {
    for_each = each.value
    content {
      effect    = statement.value["effect"]
      actions   = statement.value["actions"]
      resources = statement.value["resources"]
    }
  }
}

resource "aws_iam_policy" "custom_policies" {
  for_each = data.aws_iam_policy_document.custom_policies

  name   = each.key
  policy = each.value.json
}

resource "aws_iam_role_policy_attachment" "custom_policy_attachments" {
  for_each = aws_iam_policy.custom_policies

  role       = var.role
  policy_arn = each.value.arn
}


resource "aws_iam_role_policy_attachment" "policy_attachments" {
  for_each = module.policy_arns

  role       = var.role
  policy_arn = each.value.arn
}