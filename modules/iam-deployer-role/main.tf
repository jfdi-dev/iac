
data aws_caller_identity current {}

locals {
  account_id = data.aws_caller_identity.current.account_id
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
					actions = [
						"iam:*"
					]
					resources = [
						"arn:aws:iam::${local.account_id}:role/${var.project}-*-deployer",
						"arn:aws:iam::${local.account_id}:policy/*"
					]
				}
			]
		}
	}
}