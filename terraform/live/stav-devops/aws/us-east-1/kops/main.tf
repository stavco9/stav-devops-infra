locals {
  s3_kops_state = format("%s-kops-state", data.aws_caller_identity.account_id.account_id)
}

data "aws_caller_identity" "account_id" {}

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

  bucket = local.s3_kops_state
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