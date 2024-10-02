
data aws_caller_identity current {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

module tf-state-access-policies {
  source = "../tf-state-access"

  project = var.project
}

module deployer-role {
  source = "../deployer-role"

  depends_on = [ module.tf-state-access-policies ]

  project = var.project
  tooling_account = var.tooling_account
  artifact_name = "iam"

  named_policies = module.tf-state-access-policies.policies

  attached_policies = {
    iam-deployer-policy = [ {
      actions = [
        "iam:UpdateAssumeRolePolicy",
				"iam:ListRoleTags",
				"iam:UntagRole",
				"iam:PutRolePermissionsBoundary",
				"iam:TagRole",
				"iam:DeletePolicy",
				"iam:CreateRole",
				"iam:AttachRolePolicy",
				"iam:PutRolePolicy",
				"iam:DeleteRolePermissionsBoundary",
				"iam:DetachRolePolicy",
				"iam:DeleteRolePolicy",
				"iam:ListPolicyTags",
				"iam:ListRolePolicies",
				"iam:CreatePolicyVersion",
				"iam:GetRole",
				"iam:GetPolicy",
				"iam:DeleteRole",
				"iam:TagPolicy",
				"iam:CreatePolicy",
				"iam:ListPolicyVersions",
				"iam:UntagPolicy",
				"iam:UpdateRole",
				"iam:GetRolePolicy",
				"iam:DeletePolicyVersion",
				"iam:SetDefaultPolicyVersion"
      ]
      resources = [
        "arn:aws:iam::${local.account_id}:role/${var.project}-*-deployer",
				"arn:aws:iam::${local.account_id}:policy/*"
      ]
    } ]
  }
}