
locals {
  aws-domain = "sts.amazonaws.com"

  github-domain = "token.actions.githubusercontent.com"
  github-url = "https://${local.github-domain}"

  github_owner = var.github_owner != null ? var.github_owner : var.project

  ref = var.github_branch != null ? ":ref:refs/heads/${var.github_branch}" : ""
  repo = var.github_repo  != null ? var.github_repo : "*"
  sub = format("repo:${local.github_owner}/%s%s", local.repo, local.ref)
}

data "tls_certificate" "github" {
  url = "${local.github-url}/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github-oidc" {
  url = local.github-url

  client_id_list = [ local.aws-domain ]

  thumbprint_list = [ data.tls_certificate.github.certificates[0].sha1_fingerprint ]
}

data aws_iam_policy_document assume_role {
  statement {
    principals {
      type = "Federated"
      identifiers = [ aws_iam_openid_connect_provider.github-oidc.arn ]
    }
    
    actions = [ "sts:AssumeRoleWithWebIdentity" ]
    
    condition {
      test = "StringEquals"
      variable = "${local.github-domain}:aud"
      values = [ local.aws-domain ]
    }

    condition {
      test = "StringLike"
      variable = "${local.github-domain}:sub"
      values = [ local.sub ]
    }
  }
}

resource "aws_iam_role" "github-ci" {
  name = var.ci-role
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data aws_organizations_organization org {}

data aws_caller_identity current {}

data aws_region current {}

data aws_iam_policy_document get_project_context {
  statement {
    effect = "Allow"
    actions = [ "ssm:GetParameter" ]
    resources = [
      "arn:aws:ssm:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:parameter/project_context"
    ]
  }
}

data aws_iam_policy_document assume_other_roles {
  statement {
    effect = "Allow"
    actions = [ "sts:AssumeRole" ]
    resources = [
      for account in data.aws_organizations_organization.org.non_master_accounts:
      "arn:aws:iam::${account.id}:role/${var.project}-*-deployer"
    ]
  }
}

data aws_iam_policy_document list_accounts {
  statement {
    effect = "Allow"
    actions = [ "organizations:ListAccounts" ]
    resources = [ "*" ]
  }
}

resource aws_iam_policy assume_other_roles {
  name = "assume-other-roles"
  policy = data.aws_iam_policy_document.assume_other_roles.json
}

resource aws_iam_policy get_project_context {
  name = "get-project-context"
  policy = data.aws_iam_policy_document.get_project_context.json
}

resource aws_iam_policy list_accounts {
  name = "list-accounts"
  policy = data.aws_iam_policy_document.list_accounts.json
}

resource aws_iam_role_policy_attachment assume_other_roles {
  role = aws_iam_role.github-ci.name
  policy_arn = aws_iam_policy.assume_other_roles.arn
}

resource aws_iam_role_policy_attachment get_project_context {
  role = aws_iam_role.github-ci.name
  policy_arn = aws_iam_policy.get_project_context.arn
}

resource aws_iam_role_policy_attachment list_accounts {
  role = aws_iam_role.github-ci.name
  policy_arn = aws_iam_policy.list_accounts.arn
}
