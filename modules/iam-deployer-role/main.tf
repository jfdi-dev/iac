
data aws_caller_identity current {}

locals {
  account_id = data.aws_caller_identity.current.account_id
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

  account = var.tooling_account
  service = "ram"
  resource_type = "resource-share"
  resource_id = "*"
}

module project_context_parameter_arn {
  source = "../arn"
  
  account = var.tooling_account
  service = "ssm"
  resource_type = "parameter"
  resource_id = module.project-context-name.parameter_name
}

module deployer-role {
  source = "../deployer-role"

  project = var.project
  tooling_account = var.tooling_account
  artifact_name = "iam"

	policies = {
		custom = {
			iam-deployer = [
				{
					effect = "Allow"
					actions = [
						"iam:*"
					]
					resources = [
						"arn:aws:iam::${local.account_id}:role/${var.project}-*-deployer",
						"arn:aws:iam::${local.account_id}:policy/*"
					]
				}
			],
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
	        resources = [module.project_context_parameter_arn.value]
	      }
	    ]
		}
	}
}