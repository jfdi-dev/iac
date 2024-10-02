
locals {
  email_template = lower(var.email_template)
  project = lower(var.project)
  org = yamldecode(file("./org-structure.yaml"))
  units = toset([
    for key, element in local.org: element.name 
    if element.type == "unit" && !contains(var.omit, key)
  ])
  accounts_list = tolist(flatten([
    for key, unit in local.org:
    [
      for account_name, account in unit.children:
      tomap({
        parent_name = unit.name
        long_name = "${local.project}-${unit.shortcode}-${account_name}"
        email = templatestring(local.email_template, { account = account_name })
        policy = contains(keys(coalesce(account, {})), "policy") ? account.policy : null
      })
    ]
    if unit.type == "unit" && !contains(var.omit, key)
  ]))
  accounts = {
    for account in local.accounts_list:
    account.long_name => account
  }
  org_resource_policies = {
    for name, account in local.accounts:
    name => account.policy
    if account.policy != null
  }
}

data aws_organizations_organization org {
}

resource aws_organizations_organizational_unit unit {
  for_each = local.units
  name = each.key
  parent_id = data.aws_organizations_organization.org.roots[0].id
}

resource aws_organizations_account account {
  for_each = local.accounts
  parent_id = aws_organizations_organizational_unit.unit[each.value.parent_name].id
  name = each.key
  email = each.value.email
}

resource aws_organizations_resource_policy policy {
  for_each = local.org_resource_policies

  content = templatefile("./policies/${each.value}.tftpl", {
    account_id = aws_organizations_account.account[each.key].id
  })
}

resource aws_ram_sharing_with_organization project_context {

}