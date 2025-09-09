locals {
  project = "stav-devops"
  environment = "pre-prod"
  aws_profile = "stav-devops"
  aws_region = data.aws_region.current_region.name
  aws_account_id = data.aws_caller_identity.current_account_id.account_id
  remote_state_dynamodb_table = "tf-state-lock"
  remote_state_bucket = format("%s-terraform-state", local.aws_account_id)
  remote_state_region = "us-east-1"
  remote_state_networking_key = format("%s/networking/%s/terraform.tfstate", local.aws_region, local.environment)
  remote_state_iam_key = "iam/terraform.tfstate"
  remote_state_kops_key = format("%s/kops/%s/terraform.tfstate", local.aws_region, local.environment)
}

data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = local.remote_state_bucket
    key    = local.remote_state_networking_key
    dynamodb_table = local.remote_state_dynamodb_table
    profile = local.aws_profile
    region = local.remote_state_region
  }
}

data "terraform_remote_state" "iam" {
  backend = "s3"

  config = {
    bucket = local.remote_state_bucket
    key    = local.remote_state_iam_key
    dynamodb_table = local.remote_state_dynamodb_table
    profile = local.aws_profile
    region = local.remote_state_region
  }
}

data "terraform_remote_state" "kops" {
  backend = "s3"

  config = {
    bucket = local.remote_state_bucket
    key    = local.remote_state_kops_key
    dynamodb_table = local.remote_state_dynamodb_table
    profile = local.aws_profile
    region = local.remote_state_region
  }
}

data "aws_region" "current_region" {}
data "aws_caller_identity" "current_account_id" {}

module "kops_cluster" {
   source = "../../../../../../../modules/aws/kops//cluster"
  
   project = local.project
   environment = local.environment
   kubernetes_version = "1.33.2"

   vpc_id = data.terraform_remote_state.networking.outputs.vpc_id
   public_subnet_ids = data.terraform_remote_state.networking.outputs.public_subnet_ids
   private_subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids

   kops_state_bucket = data.terraform_remote_state.kops.outputs.kops_state_bucket_name
   public_key_file_path = data.terraform_remote_state.kops.outputs.public_key_path

   kubernetes_master_policies = data.terraform_remote_state.iam.outputs.kubernetes_master_policies
   kubernetes_nodes_policies = data.terraform_remote_state.iam.outputs.kubernetes_nodes_policies

   cluster_admin_iam_roles = ["arn:aws:iam::882709358319:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_eeb2dd0cf1e87c29"]

   ec2_instance_type = "t3a.medium"

   dns_zone = "stavco9.com"

   ## At first time of cluster creation, all these must be set to false
   enable_irsa = true
   enable_aws_load_balancer_controller = true
   enable_karpenter = true
   enable_pod_identity_webhook = true
   enable_ack_controller = true
   enable_rabbitmq_operator = true
   enable_prometheus_operator = true
   enable_argocd = true
   enable_nginx_ingress_controller = true
   enable_external_dns = true

   ack_iam_controller_policy = data.terraform_remote_state.iam.outputs.ack_iam_controller_policy
   ack_iam_controller_version = "1.5.0"
   ack_s3_controller_policy = data.terraform_remote_state.iam.outputs.ack_s3_controller_policy
   ack_s3_controller_version = "1.1.0"
   aws_load_balancer_controller_policy = data.terraform_remote_state.iam.outputs.aws_load_balancer_controller_policy
   aws_load_balancer_controller_version = "1.13.4"
   rabbitmq_operator_version = "4.4.32"
   prometheus_operator_version = "77.5.0"
   argocd_version = "8.3.5"
   nginx_ingress_controller_version = "4.13.2"
   external_dns_version = "1.19.0"
   external_dns_policy = data.terraform_remote_state.iam.outputs.external_dns_policy

   turn_off_cluster_at_night = true
   turn_off_cluster_at_night_time_zone = "Asia/Jerusalem"
   turn_off_nodes_at_night_recurrence = "0 22 * * *"
   turn_off_master_at_night_recurrence = "0 23 * * *"
}