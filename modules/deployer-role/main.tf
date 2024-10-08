
locals {
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

module local_resource_share_arn {
  source = "../arn"

  service = "ram"
  resource_type = "resource-share"
  resource_id = "*"
}

module tooling_resource_share_arn {
  source = "../arn"

  account_id = var.tooling_account
  service = "ram"
  resource_type = "resource-share"
  resource_id = "*"
}

module project_context_parameter_arn {
  source = "../arn"
  
  account_id = var.tooling_account
  service = "ssm"
  resource_type = "parameter"
  resource_id = module.project-context-name.parameter_name
}

module identity_policies {
  source = "../identity-policies"

  identity = aws_iam_role.deployment-role.arn

  policies = merge(var.policies,
  {
    custom = {
      read-project-context = [
        {
          effect = "Allow"
          actions = ["ram:GetResourceShares"]
          resources = [module.local_resource_share_arn.value]
        },
        {
          effect = "Allow"
          actions = ["ram:ListResources"]
          resources = [module.tooling_resource_share_arn.value]
        },
        {
          effect = "Allow"
          actions = ["ssm:GetParameter"]
          resource = [module.project_context_parameter_arn.value]
        }
      ]
    }
  })
}
