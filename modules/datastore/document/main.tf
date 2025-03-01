
locals {
  attributes = [
    var.keys.hash,
    var.keys.range
  ]
}

resource "aws_dynamodb_table" "documents" {
  name         = var.name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.keys.hash.name
  range_key    = var.keys.range.name

  dynamic "attribute" {
    for_each = {
      for attribute in local.attributes :
      attribute.name => attribute.type
    }
    iterator = att
    content {
      name = att.key
      type = att.value
    }
  }

  deletion_protection_enabled = true

  # point_in_time_recovery {
  #   enabled = local.dr_is_at_least_silver
  # }
}

data "aws_iam_policy_document" "datastore_access" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem"
    ]
    resources = [
      "${aws_dynamodb_table.documents.arn}",
      "${aws_dynamodb_table.documents.arn}/index/*"
    ]
  }
}

resource "aws_iam_policy" "datastore_access" {
  name   = "access-datastore-${var.name}"
  policy = data.aws_iam_policy_document.datastore_access.json
}

# resource "aws_kinesis_stream" "data_stream" {
#   count       = var.stream ? 1 : 0
#   name        = "${local.database_name}-changes"
#   shard_count = 1
# }

# resource "aws_dynamodb_kinesis_streaming_destination" "data_stream" {
#   count      = var.stream ? 1 : 0
#   stream_arn = aws_kinesis_stream.data_stream[count.index].arn
#   table_name = aws_dynamodb_table.documents.name
# }

