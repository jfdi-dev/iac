
locals {

}

data aws_caller_identity current {}

data aws_iam_policy_document tf_state_s3_bucket_access {
  statement {
    effect = "Allow"
    actions = [ 
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [ 
      "arn:aws:s3:::${var.s3_bucket_name}",
      "arn:aws:s3:::${var.s3_bucket_name}/${var.project}/${data.aws_caller_identity.current.account_id}/*",
    ]
  }
}

resource aws_iam_policy tf_state_s3_bucket_access {
  name = "tf_state_s3_bucket_access"
  policy = data.aws_iam_policy_document.tf_state_s3_bucket_access.json
}

data aws_iam_policy_document tf_state_dynamodb_table_access {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [
      "arn:aws:dynamodb:*:*:table/${var.dynamo_table_name}"
    ]
  }
}

resource aws_iam_policy tf_state_dynamodb_table_access {
  name = "tf_state_dynamodb_table_access"
  policy = data.aws_iam_policy_document.tf_state_dynamodb_table_access.json
}