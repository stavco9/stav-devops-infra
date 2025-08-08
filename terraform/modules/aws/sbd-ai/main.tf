locals {
  environment = var.environment

  tags = {
    Environment = local.environment
    Region = local.current_region
    Project = var.project
    Owner = var.project
    ManagedBy = "terraform"
  }

  # Get current region
  current_region = data.aws_region.current.name
  current_account_id = data.aws_caller_identity.account_id.account_id

  mongodbatlas_provider_name = "TENANT"
  mongodbatlas_cloud_provider = "AWS"
  mongodbatlas_instance_size = "M0"

  sbd_ai_videos_bucket = format("%s-%s-%s-videos-%s", local.current_account_id, local.current_region, var.project, local.environment)
  sbd_ai_mongodb_cluster = format("%s-mongodb-%s", var.project, local.environment)
}

data "aws_caller_identity" "account_id" {}
data "aws_region" "current" {}
data "mongodbatlas_roles_org_id" "current" {}

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

  tags = merge(local.tags, {
    Name = local.sbd_ai_videos_bucket
  })
}

resource "mongodbatlas_project" "sbd_ai" {
  count = var.create_mongodb_cluster ? 1 : 0

  name = local.sbd_ai_mongodb_cluster
  org_id = data.mongodbatlas_roles_org_id.current.org_id
  tags = merge(local.tags, {
    Name = local.sbd_ai_mongodb_cluster
  })
}

resource "mongodbatlas_project_ip_access_list" "sbd_ai" {
  count = var.create_mongodb_cluster ? 1 : 0

  project_id = mongodbatlas_project.sbd_ai[0].id
  cidr_block = var.environment == "dev" ? "0.0.0.0/0" : null
}

resource "mongodbatlas_cluster" "sbd_ai" {
  count = var.create_mongodb_cluster ? 1 : 0

  project_id              = mongodbatlas_project.sbd_ai[0].id
  name                    = local.sbd_ai_mongodb_cluster

  # Provider Settings "block"
  provider_name = local.mongodbatlas_provider_name
  backing_provider_name = local.mongodbatlas_cloud_provider
  provider_region_name = upper(replace(local.current_region, "-", "_"))
  provider_instance_size_name = local.mongodbatlas_instance_size

  dynamic "tags" {
    for_each = merge(local.tags, {
      Name = local.sbd_ai_mongodb_cluster
   })
    content {
      key = tags.key
      value = tags.value
    }
  }
}

resource "mongodbatlas_database_user" "sbd_ai" {
  count = var.create_mongodb_cluster ? length(var.mongodb_iam_roles_access) : 0

  project_id = mongodbatlas_project.sbd_ai[0].id
  username = var.mongodb_iam_roles_access[count.index]
  auth_database_name = "$external"
  aws_iam_type       = "ROLE"

  roles {
    database_name = "admin"
    role_name     = "readWriteAnyDatabase"
  }

  dynamic "labels" {
    for_each = merge(local.tags, {
      Name = var.mongodb_iam_roles_access[count.index]
      Role = "readWriteAnyDatabase"
   })
    content {
      key = labels.key
      value = labels.value
    }
  }
}