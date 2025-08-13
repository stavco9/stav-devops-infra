locals {
  project = var.project
  environment = var.environment
  current_account_id = data.aws_caller_identity.current.account_id
  current_region = data.aws_region.current.name

  tags = {
    Environment = local.environment
    Region = local.current_region
    Project = local.project
    Owner = local.project
    ManagedBy = "terraform"
  }

  kops_state_bucket = format("%s-%s-%s-kops-state-%s", local.current_account_id, local.current_region, local.project, local.environment)
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_openssh
  filename = "${path.root}/private_key.pem"
}

resource "local_file" "public_key" {
  content  = tls_private_key.ssh_key.public_key_openssh
  filename = "${path.root}/public_key.pem"
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.kops_state_bucket
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
    Name = local.kops_state_bucket
  })
}