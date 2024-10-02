variable project {
  type = string
}

variable s3_bucket_name {
  type = string
  default = "tf-state"
}

variable dynamo_table_name {
  type = string
  default = "tf-state-locks"
}
