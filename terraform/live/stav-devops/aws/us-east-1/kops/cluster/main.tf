data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = format("%s-terraform-state", data.aws_caller_identity.account_id.account_id)
    key    = format("%s/networking/terraform.tfstate", data.aws_region.region.name)
    dynamodb_table = "tf-state-lock"
    profile = "stav-devops"
    region = data.aws_region.region.name
  }
}

data "terraform_remote_state" "kops_prerequisists" {
  backend = "s3"

  config = {
    bucket = format("%s-terraform-state", data.aws_caller_identity.account_id.account_id)
    key    = format("%s/kops/terraform.tfstate", data.aws_region.region.name)
    dynamodb_table = "tf-state-lock"
    profile = "stav-devops"
    region = data.aws_region.region.name
  }
}

data "aws_route53_zone" "dns_zone" {
  name         = local.dns_zone
  private_zone = false
}

data "http" "load_balancer_controller_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.1/docs/install/iam_policy.json"
}

data "aws_caller_identity" "account_id" { }

data "aws_region" "region" { }

locals {
  vpc_id = data.terraform_remote_state.networking.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids
  public_subnet_ids = data.terraform_remote_state.networking.outputs.public_subnet_ids
  subnet_azs = data.terraform_remote_state.networking.outputs.subnet_azs
  all_subnets = concat([ for i, v in local.private_subnet_ids :
    {
        "subnet_id" = v,
        "az_name" = local.subnet_azs[i]
    }
  ],
  [ for i, v in local.public_subnet_ids :
    {
        "subnet_id" = v,
        "az_name" = local.subnet_azs[i]
    }
  ])
  ssm_policy = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  cluster_name = "k8s.stav-devops.stavco9.com"
  dns_zone = "stavco9.com"
  cluster_project = "stav-devops"
  instance_type = "t3.small"
}

resource "aws_iam_policy" "load_balancer_controller_policy" {
  name = "AWSLoadBalancerControllerIAMPolicy"
  policy = data.http.load_balancer_controller_policy.response_body
}

resource "aws_iam_policy" "external_dns_policy" {
  name = "AllowExternalDNSUpdates"
  policy = file("./route53-permissions.json")
}

resource "aws_acm_certificate" "master_cert" {
  domain_name       = "api.${local.cluster_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
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
  zone_id         = data.aws_route53_zone.dns_zone.zone_id
}

resource "aws_acm_certificate_validation" "master_cert_validate" {
  certificate_arn         = aws_acm_certificate.master_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.master_cert_validate : record.fqdn]
}

resource "kops_cluster" "cluster" {
  name                 = local.cluster_name
  admin_ssh_key        = file(data.terraform_remote_state.kops_prerequisists.outputs.public_key_path)
  kubernetes_version   = "1.21.0"
  dns_zone             = local.dns_zone
  master_public_name   = "api.${local.cluster_name}"
  network_id           = local.vpc_id
  kubernetes_api_access = ["0.0.0.0/0"]

  cloud_provider {
    aws {}
  }

  iam {
    allow_container_registry = true
  }

  networking {
    calico {}
  }

  topology {
    masters = "public"
    nodes   = "private"

    dns {
      type = "Public"
    }
  }

  # cluster subnets
  dynamic "subnet" {
    for_each = local.all_subnets
    content {
        name = subnet.value.subnet_id
        provider_id = subnet.value.subnet_id
        type        = "Private"
        zone = subnet.value.az_name
    }
  }

  # etcd clusters
  etcd_cluster {
    name            = "main"

    member {
      name             = "master-0"
      instance_group   = "master-0"
    }
  }

  etcd_cluster {
    name            = "events"

    member {
      name             = "master-0"
      instance_group   = "master-0"
    }
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
            for_each = local.public_subnet_ids
            content {
                name = subnets.value
            }
        }
    }
  }

  external_policies {
    key = "master"
    value = [ local.ssm_policy ]
  }

  external_policies {
    key = "node"
    value = [ local.ssm_policy,
    aws_iam_policy.load_balancer_controller_policy.arn,
    aws_iam_policy.external_dns_policy.arn
     ]
  }

  #cert_manager {
  #  enabled = true
  #  managed = true
  #}

  #aws_load_balancer_controller {
  #  enabled = true
  #}

  metrics_server {
    enabled = true
    insecure = true
  }

  cloud_config {
    aws_ebs_csi_driver {
        enabled = true
    }
  }

  #authentication {
  #  aws {
  #      identity_mappings {
  #          arn = 
  #      }
  #  }
  #}

  rolling_update {
    drain_and_terminate = false
  }
}

resource "kops_instance_group" "master-0" {
  cluster_name = kops_cluster.cluster.name
  name         = "master-0"
  role         = "Master"
  min_size     = 1
  max_size     = 1
  machine_type = local.instance_type
  subnets      = [local.private_subnet_ids[0]]
  #zones        = [local.subnet_azs[0]]
  depends_on   = [kops_cluster.cluster]
  root_volume_size = 15
}

resource "kops_instance_group" "node-0" {
  cluster_name = kops_cluster.cluster.name
  name         = "node-0"
  role         = "Node"
  min_size     = 3
  max_size     = 3
  machine_type = local.instance_type
  subnets      = local.private_subnet_ids
  #zones        = local.subnet_azs
  depends_on   = [kops_cluster.cluster]
  autoscale = true
  root_volume_size = 30
}

resource "kops_cluster_updater" "updater" {
  cluster_name        = kops_cluster.cluster.name

  keepers = {
    cluster  = kops_cluster.cluster.revision
    master-0 = kops_instance_group.master-0.revision
    node-0 = kops_instance_group.node-0.revision
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
    kops_instance_group.master-0,
    kops_instance_group.node-0
  ]
}

data "kops_kube_config" "kube_config" {
  cluster_name = local.cluster_name
}