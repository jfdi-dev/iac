
data aws_caller_identity current {}

data aws_region region {}

module accounts {
  source = "../../modules/account-lookup"

  project = var.project
}

locals {
  tooling_account = data.aws_caller_identity.current.account_id
  security_account = module.accounts.security_account
  networking_account = module.accounts.networking_account
  dev_account = module.accounts.dev_account
  test_account = module.accounts.test_account
  prod_account = module.accounts.prod_account
  primary_region = data.aws_region.region.name
  secondary_region = var.secondary_region
}

module tf_state {
  source = "../../modules/tf-s3-state"

  project = var.project
}

module ci_oidc {
  source = "../../modules/github-oidc"

  project = var.project

  github_owner = var.github_owner
  github_branch = var.github_branch
  github_repo = var.github_repo
}

module project_context {
  source = "../../modules/project-context/writer"

  project = var.project
  tldp1 = var.tldp1

  regions = {
    primary = local.primary_region
    secondary = var.secondary_region
  }

  terraform = {
    state = module.tf_state.tf_state_s3_bucket_arn
    locks = module.tf_state.tf_state_locks_dynamodb_table_arn
  }
  
  tooling_account = local.tooling_account
  networking_account = local.networking_account
  security_account = local.security_account
  dev_account = local.dev_account
  test_account = local.test_account
  prod_account = local.prod_account
}