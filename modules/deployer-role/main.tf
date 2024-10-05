
data aws_caller_identity current {}

locals {
  # coalesce any nulls from the passed-in policies
  policies = {
    custom = coalesce(var.policies.custom, {})
    named = coalesce(var.policies.named, [])
    managed = coalesce(var.policies.managed, [])
  }

  managed_policy_arns = tomap({
    for managed_policy_name in local.policies.managed: 
    managed_policy_name => "arn:aws:iam::aws:policy/${managed_policy_name}"
  })

  named_policy_arns = tomap({
    for named_policy_name in local.policies.named:
    named_policy_name => "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${named_policy_name}"
  })

  assume-role-policy = jsonencode({
    Version: "2012-10-17"
    Statement: [
      {
        Effect: "Allow"
        Principal: {
            AWS: "arn:aws:iam::${var.tooling_account}:root"
        }
        Action: "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "deployment-role" {
  name = "${var.project}-${lower(var.artifact_name)}-deployer"
  assume_role_policy = local.assume-role-policy
}

module project-context-name {
  source = "../project-context"
}

data aws_region current {}

data aws_iam_policy_document read-project-context {
  statement {
    effect = "Allow"
    actions = [ 
      "ram:GetResourceShares", 
    ]
    resources = [ "arn:aws:ram:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:resource-share/*" ]
  }

  statement {
    effect = "Allow"
    actions = [ 
      "ram:ListResources" 
    ]
    resources = [ "arn:aws:ram:${data.aws_region.current.id}:${var.tooling_account}:resource-share/*" ]
  }

  statement {
    effect = "Allow"
    actions = [ "ssm:GetParameter" ]
    resources = [ "arn:aws:ssm:${data.aws_region.current.id}:${var.tooling_account}:parameter/${module.project-context-name.parameter_name}" ]
  }
}

resource "aws_iam_role_policy" "read-project-context" {
  role = aws_iam_role.deployment-role.id
  name = "read-project-context"
  policy = data.aws_iam_policy_document.read-project-context.json
}

output "deployment-role-arn" {
  value = aws_iam_role.deployment-role.arn
}

data "aws_iam_policy_document" "policies" {
  for_each = local.policies.custom
  dynamic "statement" {
    for_each = each.value
    content {
      effect = statement.value["effect"]
      actions = statement.value["actions"]
      resources = statement.value["resources"]
    }
  }
}

resource "aws_iam_policy" "policies" {
  for_each = { for idx, policy in data.aws_iam_policy_document.policies: idx => policy }
  name = each.key
  policy = each.value.json
}

resource "aws_iam_role_policy_attachment" "deployment-role-policy" {
  for_each = aws_iam_policy.policies

  role = aws_iam_role.deployment-role.name
  policy_arn = each.value.arn
}

resource aws_iam_role_policy_attachment named_policies {
  for_each = local.named_policy_arns

  role = aws_iam_role.deployment-role.name
  policy_arn = each.value
}

resource aws_iam_role_policy_attachment managed_policies {
  for_each = local.managed_policy_arns

  role = aws_iam_role.deployment-role.name
  policy_arn = each.value
}