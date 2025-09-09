locals {
  project = var.project
  environment = var.environment
  vpc_id = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  public_subnet_ids = var.public_subnet_ids
  aws_region = data.aws_region.region.name
  aws_account_id = data.aws_caller_identity.account_id.account_id
  private_subnets = [ for i, v in local.private_subnet_ids :
    {
        "subnet_id" = v,
        "az_name" = data.aws_subnet.private_subnets[v].availability_zone
        "name" = lookup(data.aws_subnet.private_subnets[v].tags, "Name", v)
    }
  ]
  public_subnets = [ for i, v in local.public_subnet_ids :
    {
        "subnet_id" = v,
        "az_name" = data.aws_subnet.public_subnets[v].availability_zone
        "name" = lookup(data.aws_subnet.public_subnets[v].tags, "Name", v)
    }
  ]
  private_subnet_names = [ for s in local.private_subnets : "${s.name}-${s.az_name}" ]
  public_subnet_names  = [ for s in local.public_subnets  : "${s.name}-${s.az_name}" ]
  all_subnets = concat(local.private_subnets, local.public_subnets)
  cluster_name = format("k8s.%s.%s.%s.%s", local.project, local.aws_region, local.environment, local.dns_zone_name)
  dns_zone_name  = var.dns_zone
  cluster_project = var.project
  dns_zone_id = data.aws_route53_zone.dns_zone.zone_id
  instance_type = var.ec2_instance_type
  master_volume_size = var.master_volume_size
  node_volume_size = var.node_volume_size
  public_key_file_path = var.public_key_file_path
  kubernetes_version = var.kubernetes_version

  kubernetes_master_group = "master"
  kubernetes_node_group = "node-general"
  oidc_provider_discovery_bucket = format("%s-%s-%s-irsa-discovery-%s", local.aws_account_id, local.aws_region, local.project, local.environment)

  master_asg = format("%s.masters.%s", local.kubernetes_master_group, local.cluster_name)
  node_asg = format("%s.%s", local.kubernetes_node_group, local.cluster_name)

  ack_namespace = "ack-system"
  ack_iam_controller_name = "ack-iam-controller"
  ack_s3_controller_name = "ack-s3-controller"
  aws_load_balancer_controller_name = "aws-load-balancer-controller"
  external_dns_name = "external-dns"

  tags = {
    Environment = local.environment
    Region = local.aws_region
    Project = local.project
    Owner = local.project
    ManagedBy = "terraform"
    Cluster = local.cluster_name
  }
}

data "aws_route53_zone" "dns_zone" {
  name         = local.dns_zone_name
  private_zone = false
}

data "aws_subnet" "private_subnets" {
  for_each = toset(local.private_subnet_ids)
  id       = each.value
}

data "aws_subnet" "public_subnets" {
  for_each = toset(local.public_subnet_ids)
  id       = each.value
}

data "aws_caller_identity" "account_id" { }

data "aws_region" "region" { }

data "kops_kube_config" "kube_config" {
  cluster_name = kops_cluster.cluster.name
}