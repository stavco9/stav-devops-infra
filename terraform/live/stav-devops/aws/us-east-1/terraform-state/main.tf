locals {
  s3_terraform_state = format("%s-terraform-state", data.aws_caller_identity.account_id.account_id)
  dynamodb_table = "tf-state-lock"
}

data "aws_caller_identity" "account_id" {}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.s3_terraform_state
  #acl    = "private"

  attach_public_policy = false
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = false
  restrict_public_buckets = true

  versioning = {
    enabled = true
  }
}

module "dynamodb_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"

  name     = local.dynamodb_table
  hash_key = "LockID"

  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]

  billing_mode = "PAY_PER_REQUEST"
}