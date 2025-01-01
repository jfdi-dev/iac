
#
# `ARN`
# =====
#
# Given some constituent parts of an ARN, returns a full-formed ARN value.
#
# Behaviour varies depending on the values of variables (eg: region/account as null = use ambient region/account id, vs region/account as "" = use blanks in the ARN) 
#


data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  partition = var.partition
  service   = var.service
  region    = var.region != null ? var.region : data.aws_region.current.id
  account   = var.account != null ? var.account : data.aws_caller_identity.current.account_id

  resource = var.resource_type != "*" ? "${var.resource_type}/${var.resource_id}" : var.resource_type

  arn = "arn:${local.partition}:${local.service}:${local.region}:${local.account}:${local.resource}"
}

