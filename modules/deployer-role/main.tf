
locals {
  assume-role-policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Effect : "Allow"
        Principal : {
          AWS : "arn:aws:iam::${var.tooling_account}:root"
        }
        Action : "sts:AssumeRole"
      }
    ]
  })

  policies = {
    custom  = coalesce(var.policies.custom, {})
    named   = coalesce(var.policies.named, [])
    managed = coalesce(var.policies.managed, [])
    service = coalesce(var.policies.service, [])
  }
}

resource "aws_iam_role" "deployment-role" {
  name               = "${var.project}-${lower(var.artifact_name)}-deployer"
  assume_role_policy = local.assume-role-policy
}

module "role_policies" {
  source = "../role-policies"

  role = aws_iam_role.deployment-role.name


  policies = {
    custom  = var.namespace ? { for k, v in local.policies.custom : "${var.artifact_name}-${k}" => v } : local.policies.custom
    named   = setunion(local.policies.named, toset(["read-project-context"]))
    managed = local.policies.managed
    service = local.policies.service
  }
}