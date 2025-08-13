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

module "oidc_provider_discovery_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.oidc_provider_discovery_bucket
  #acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_public_policy = false
  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false

  versioning = {
    enabled = true
  }

  tags = merge(local.tags, {
    Name = local.oidc_provider_discovery_bucket
  })
}

### DNS Zone

resource "aws_acm_certificate" "master_cert" {
  domain_name       = "api.${local.cluster_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.tags, {
    Name = "api.${local.cluster_name}"
  })
}

resource "aws_route53_record" "master_cert_validate" {
  for_each = {
    for dvo in aws_acm_certificate.master_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = local.dns_zone_id
}

resource "aws_acm_certificate_validation" "master_cert_validate" {
  certificate_arn         = aws_acm_certificate.master_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.master_cert_validate : record.fqdn]
}

## Kops Cluster

resource "kops_cluster" "cluster" {
  name                 = local.cluster_name
  admin_ssh_key        = file(var.public_key_file_path)
  kubernetes_version   = local.kubernetes_version
  dns_zone             = local.dns_zone_name


  iam {
    allow_container_registry = true
    use_service_account_external_permissions = var.enable_irsa
  }

  service_account_issuer_discovery {
    discovery_store = "s3://${local.oidc_provider_discovery_bucket}"
    enable_aws_oidc_provider = var.enable_irsa
  }

  karpenter {
    enabled = var.enable_karpenter
  }

  kube_api_server {
    kubelet_preferred_address_types = [ "InternalDNS", "InternalIP", "Hostname", "ExternalDNS", "ExternalIP" ]
  }

  networking {
    network_id = local.vpc_id
    # cluster subnets
    dynamic "subnet" {
      for_each = local.public_subnets
      content {
          name = "${subnet.value.name}-${subnet.value.az_name}"
          id   = subnet.value.subnet_id
          type        = "Public"
          zone = subnet.value.az_name
      }
    }

    dynamic "subnet" {
      for_each = local.private_subnets
      content {
          name = "${subnet.value.name}-${subnet.value.az_name}"
          id   = subnet.value.subnet_id
          type        = "Private"
          zone = subnet.value.az_name
      }
    } 
    
    topology {
      dns = "Public"
    }

    calico {}
  }

  # etcd clusters
  etcd_cluster {
    name            = "main"

    member {
      name             = local.kubernetes_master_group
      instance_group   = local.kubernetes_master_group
    }
  }

  etcd_cluster {
    name            = "events"

    member {
      name             = local.kubernetes_master_group
      instance_group   = local.kubernetes_master_group
    }
  }

  kube_dns {
    provider = "CoreDNS"
  }

  external_dns {
    watch_ingress = true
    provider = "dns-controller"
  }

  api {
    dns { }
    load_balancer {
        class = "Network"
        type = "Public"
        use_for_internal_api = false
        ssl_certificate = aws_acm_certificate.master_cert.arn
        ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
        
        dynamic "subnets" {
            for_each = local.public_subnets
            content {
                name = "${subnets.value.name}-${subnets.value.az_name}"
            }
        }
    }
    access = [ "0.0.0.0/0" ]
  }

  external_policies {
    key = "control-plane"
    value = var.kubernetes_master_policies
  }

  external_policies {
    key = "node"
    value = var.kubernetes_nodes_policies
  }

  config_store {
    base = "s3://${var.kops_state_bucket}"
  }

  cert_manager {
    enabled = true
    managed = true
  }

  cloud_provider {
    aws {
      ebs_csi_driver {
        enabled = true
        managed = true
      }

      load_balancer_controller {
        enabled = var.enable_aws_load_balancer_controller
      }

      pod_identity_webhook {
        enabled = var.enable_pod_identity_webhook
      }
    }
  }

  metrics_server {
    enabled = true
    insecure = true
  }

  authentication {
    aws {
        backend_mode = "CRD"
        dynamic "identity_mappings" {
            for_each = var.cluster_admin_iam_roles != null ? var.cluster_admin_iam_roles : []
            content {
                arn = identity_mappings.value
                groups = ["system:masters"]
            }
        }
    }
  }

  rolling_update {
    drain_and_terminate = false
  }

  depends_on = [ module.oidc_provider_discovery_bucket ]
}

resource "kops_instance_group" "master" {
  cluster_name = kops_cluster.cluster.name
  name         = local.kubernetes_master_group
  role         = "ControlPlane"
  min_size     = 1
  max_size     = 1
  machine_type = local.instance_type
  subnets      = [local.private_subnet_names[0]]
  root_volume {
    size = local.master_volume_size
    type = "gp3"
  }
  depends_on   = [kops_cluster.cluster]
}

resource "kops_instance_group" "node_general" {
  cluster_name = kops_cluster.cluster.name
  name         = local.kubernetes_node_group
  role         = "Node"
  min_size     = 2
  max_size     = 3
  machine_type = local.instance_type
  subnets      = local.private_subnet_names
  autoscale = true
  root_volume {
    size = local.node_volume_size
    type = "gp3"
  }
  depends_on   = [kops_cluster.cluster]
}

resource "kops_cluster_updater" "updater" {
  cluster_name        = kops_cluster.cluster.name

  keepers = {
    cluster  = kops_cluster.cluster.revision
    master = kops_instance_group.master.revision
    node_general = kops_instance_group.node_general.revision
  }

  rolling_update {
    skip                = false
    fail_on_drain_error = true
    fail_on_validate    = true
    validate_count      = 1
  }

  validate {
    skip = false
  }

  # ensures rolling update happens after the cluster and instance groups are up to date
  depends_on   = [
    kops_cluster.cluster,
    kops_instance_group.master,
    kops_instance_group.node_general
  ]
}

data "kops_kube_config" "kube_config" {
  cluster_name = kops_cluster.cluster.name
}