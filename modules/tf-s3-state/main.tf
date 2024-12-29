
data "aws_caller_identity" "current" {}

data "aws_organizations_organization" "org" {}

locals {
  s3_bucket_name    = "state.terraform.${var.project}"
  dynamo_table_name = "lock.state.terraform.${var.project}"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = local.s3_bucket_name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_iam_policy_document" "s3_bucket_cross_account_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${local.s3_bucket_name}",
      "arn:aws:s3:::${local.s3_bucket_name}/*"
    ]
    principals {
      type = "AWS"
      identifiers = [
        for account in data.aws_organizations_organization.org.non_master_accounts :
        account.id
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.bucket
  policy = data.aws_iam_policy_document.s3_bucket_cross_account_access.json
}

resource "aws_dynamodb_table" "terraform_state_locks" {
  name = local.dynamo_table_name

  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

data "aws_iam_policy_document" "dynamodb_cross_account_access" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [
      "arn:aws:dynamodb:*:*:table/${local.dynamo_table_name}"
    ]
    principals {
      type = "AWS"
      identifiers = [
        for account in data.aws_organizations_organization.org.non_master_accounts :
        account.id
      ]
    }
  }
}

resource "aws_dynamodb_resource_policy" "cross_account_access" {
  resource_arn = aws_dynamodb_table.terraform_state_locks.arn
  policy       = data.aws_iam_policy_document.dynamodb_cross_account_access.json
}
