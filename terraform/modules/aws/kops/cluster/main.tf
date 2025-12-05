## Kops Cluster

resource "kops_cluster" "cluster" {
  name                 = local.cluster_name
  admin_ssh_key        = file(var.public_key_file_path)
  kubernetes_version   = local.kubernetes_version
  dns_zone             = local.dns_zone_name


  iam {
    allow_container_registry = true
    use_service_account_external_permissions = var.enable_irsa

    dynamic "service_account_external_permissions" {
      for_each = var.enable_ack_controller ? [1] : []
        content {
          name = local.ack_iam_controller_name
          namespace = local.ack_namespace
          aws{
            policy_ar_ns = [var.ack_iam_controller_policy]
          }
      }
    }

    dynamic "service_account_external_permissions" {
      for_each = var.enable_ack_controller ? [1] : []
        content {
          name = local.ack_s3_controller_name
          namespace = local.ack_namespace
          aws{
            policy_ar_ns = [var.ack_s3_controller_policy]
          }
      }
    }

    dynamic "service_account_external_permissions" {
      for_each = var.enable_aws_load_balancer_controller ? [1] : []
        content {
          name = local.aws_load_balancer_controller_name
          namespace = "kube-system"
          aws{
            policy_ar_ns = [var.aws_load_balancer_controller_policy]
          }
      }
    }

    dynamic "service_account_external_permissions" {
      for_each = var.enable_external_dns ? [1] : []
        content {
          name = local.external_dns_name
          namespace = "kube-system"
          aws{
            policy_ar_ns = [var.external_dns_policy]
          }
      }
    }

    dynamic "service_account_external_permissions" {
      for_each = var.custom_apps_iam_roles
        content {
          name = service_account_external_permissions.value.service_account_name
          namespace = service_account_external_permissions.value.service_account_namespace
          aws{
            policy_ar_ns = service_account_external_permissions.value.iam_policy_arns
          }
      }
    }
  }

  service_account_issuer_discovery {
    discovery_store = "s3://${local.oidc_provider_discovery_bucket}"
    enable_aws_oidc_provider = var.enable_irsa
  }

  karpenter {
    enabled = var.enable_karpenter
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
        enabled = false ## Install separately via helm chart due to issues with kOpsq
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
  
  instance_metadata {
    http_tokens = "optional"
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
  
  instance_metadata {
    http_tokens = "optional"
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