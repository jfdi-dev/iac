
locals {
  logs_bucket = "logs.${var.name}"
}

# module "dr-from-env" {
#   source = "../dr-from-env"
# }

# module "dr" {
#   source = "../disaster-recovery"

#   level = module.dr-from-env.level
# }

resource "aws_s3_bucket" "logs" {
  bucket = local.logs_bucket
}

resource "aws_s3_bucket" "content" {
  bucket = var.name
}

resource "aws_s3_bucket_logging" "logging" {
  bucket = aws_s3_bucket.content.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "logs/"
}

resource "aws_s3_bucket_ownership_controls" "logging" {
  bucket = aws_s3_bucket.logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.content.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.content.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "logging" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#
# TODO
#
# resource "aws_s3_bucket_replication_configuration" "replication" {
#   count = dr.at_least_silver ? 1 : 0

#   depends_on = [ aws_s3_bucket_versioning.source ]

#   role = aws_iam_role.replication.arn
#   bucket = aws_s3_bucket.content

#   rule {
#     id = "all"

#     status = "Enabled"

#     destination {
#       aws_s3_bucket.replica.arn
#       storage_class = "STANDARD"
#     }
#   }
# }

#
# In CDN:
#

# data "aws_iam_policy_document" "policy" {
#   statement {
#     principals {

#     }
#     actions = [

#     ]
#     resources = [ 

#      ]
#   }
# }

# resource "aws_s3_bucket_policy" "policy" {
#   bucket = aws_s3_bucket.content
#   policy = data.aws_iam_policy_document.policy.json
# }

