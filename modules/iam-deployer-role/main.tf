
data aws_caller_identity current {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

module deployer-role {
  source = "../deployer-role"

  project = var.project
  tooling_account = var.tooling_account
  artifact_name = "iam"

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