
data aws_caller_identity current {}

locals {
  managed_policy_arns = tomap({
    for managed_policy_name in var.policies.managed: 
    managed_policy_name => "arn:aws:iam::aws:policy/${managed_policy_name}"
  })

  named_policy_arns = tomap({
    for named_policy_name in var.policies.named:
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

output "deployment-role-arn" {
  value = aws_iam_role.deployment-role.arn
}

data "aws_iam_policy_document" "policies" {
  for_each = var.policies.custom
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