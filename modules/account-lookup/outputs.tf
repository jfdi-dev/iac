
output "accounts" {
  value = local.accounts
}

output "tooling_account" {
  value = local.accounts["tooling"].id

  precondition {
    condition = contains(keys(local.accounts), "tooling") && local.accounts["tooling"] != null
    error_message = "No `tooling` account found..."
  }
}

output "networking_account" {
  value = local.accounts["networking"].id

  precondition {
    condition = contains(keys(local.accounts), "networking") && local.accounts["networking"] != null
    error_message = "No `networking` account found..."
  }
}

output "security_account" {
  value = local.accounts["security"].id
  
  precondition {
    condition = contains(keys(local.accounts), "security") && local.accounts["security"] != null
    error_message = "No `security` account found..."
  }
}

output "development_account" {
  value = local.accounts["development"].id

  precondition {
    condition = contains(keys(local.accounts), "development") && local.accounts["development"] != null
    error_message = "No `development` account found..."
  }
}

output "staging_account" {
  value = local.accounts["staging"].id

  precondition {
    condition = contains(keys(local.accounts), "staging") && local.accounts["staging"] != null
    error_message = "No `staging` account found..."
  }
}

output "production_account" {
  value = local.accounts["production"].id

  precondition {
    condition = contains(keys(local.accounts), "production") && local.accounts["production"] != null
    error_message = "No `production` account found..."
  }
}