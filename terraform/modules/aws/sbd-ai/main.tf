locals {
  environment = var.environment

  tags = {
    Name = local.sbd_ai_videos_bucket
    Environment = local.environment
    Region = local.current_region
    Project = "sbd-ai"
    Owner = "stav-devops"
    ManagedBy = "terraform"
  }

  # Get current region
  current_region = data.aws_region.current.name
  current_account_id = data.aws_caller_identity.account_id.account_id

  sbd_ai_videos_bucket = format("%s-%s-sbdai-videos-%s", local.current_account_id, local.current_region, local.environment)
}

data "aws_caller_identity" "account_id" {}
data "aws_region" "current" {}

module "s3_bucket" {
  count = var.create_bucket ? 1 : 0

  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.sbd_ai_videos_bucket
  #acl    = "private"

  attach_public_policy = false
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = false
  restrict_public_buckets = true

  versioning = {
    enabled = true
  }

  tags = local.tags
}