
output "accounts" {
  value = local.accounts
}

output "tooling" {
  value = local.accounts["tooling"]

  precondition {
    condition     = contains(keys(local.accounts), "tooling") && local.accounts["tooling"] != null
    error_message = "No `tooling` account found..."
  }
}

output "networking" {
  value = local.accounts["networking"]

  precondition {
    condition     = contains(keys(local.accounts), "networking") && local.accounts["networking"] != null
    error_message = "No `networking` account found..."
  }
}

output "security" {
  value = local.accounts["security"]

  precondition {
    condition     = contains(keys(local.accounts), "security") && local.accounts["security"] != null
    error_message = "No `security` account found..."
  }
}

output "development" {
  value = local.accounts["development"]

  precondition {
    condition     = contains(keys(local.accounts), "development") && local.accounts["development"] != null
    error_message = "No `development` account found..."
  }
}

output "staging" {
  value = local.accounts["staging"]

  precondition {
    condition     = contains(keys(local.accounts), "staging") && local.accounts["staging"] != null
    error_message = "No `staging` account found..."
  }
}

output "production" {
  value = local.accounts["production"]

  precondition {
    condition     = contains(keys(local.accounts), "production") && local.accounts["production"] != null
    error_message = "No `production` account found..."
  }
}