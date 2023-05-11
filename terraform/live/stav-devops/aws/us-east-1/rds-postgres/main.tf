
locals {
  common_tags = {
    "Projects"    = local.project,
    "Environment" = local.env,
    "Terraform"   = true
  }

  project = "flask-sample"
  env     = "DEV"

  postgres_version      = "14"
  postgres_db           = "flask"
  postgres_user         = "flask"
  postgres_password     = random_password.db_password.result
  postgres_access_cidrs = ["10.0.0.0/23"] #data.terraform_remote_state.networking.outputs.vpc_cidr
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

data "aws_partition" "curr_partition" {}

data "aws_caller_identity" "curr_account" {}

data "aws_region" "curr_region" {}

data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket         = format("%s-terraform-state", data.aws_caller_identity.curr_account.account_id)
    key            = format("%s/networking/terraform.tfstate", data.aws_region.curr_region.name)
    dynamodb_table = "tf-state-lock"
    profile        = "stav-devops"
    region         = data.aws_region.curr_region.name
  }
}

module "rds_postgres" {
  source = "../../../../../modules/aws/postgres"

  env              = local.env
  project          = local.project
  db_name          = local.postgres_db
  db_user          = local.postgres_user
  db_password      = local.postgres_password
  db_version       = local.postgres_version
  vpc_id           = data.terraform_remote_state.networking.outputs.vpc_id
  db_subnet_group  = data.terraform_remote_state.networking.outputs.private_db_subnet_group
  rds_access_cidrs = local.postgres_access_cidrs
}