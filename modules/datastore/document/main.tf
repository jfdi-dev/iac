
locals {
  suffix        = var.aggregate ? "-${var.aggregate}" : ""
  database_name = "${var.context}${local.suffix}"
  attributes = concat(
    [
      var.primary_key,
      var.sort_by
    ],
    var.attributes
  )
  dr_is_at_least_silver = contains(["SILVER", "GOLD"], var.dr_level)
}

resource "aws_dynamodb_table" "documents" {
  name           = local.database_name
  billing_mode   = "PROVISIONED"
  read_capacity  = var.capacity.read
  write_capacity = var.capacity.write
  hash_key       = var.primary_key.name
  range_key      = var.sort_by.name

  dynamic "attribute" {
    for_each = {
      for attribute in local.attributes :
      attribute.name => attribute.type
    }
    content {
      name = each.key
      type = each.value
    }
  }

  deletion_protection_enabled = true

  point_in_time_recovery {
    enabled = local.dr_is_at_least_silver
  }
}

resource "aws_kinesis_stream" "data_stream" {
  count       = var.stream ? 1 : 0
  name        = "${local.database_name}-changes"
  shard_count = 1
}

resource "aws_dynamodb_kinesis_streaming_destination" "data_stream" {
  count      = var.stream ? 1 : 0
  stream_arn = aws_kinesis_stream.data_stream[count.index].arn
  table_name = aws_dynamodb_table.documents.name
}

