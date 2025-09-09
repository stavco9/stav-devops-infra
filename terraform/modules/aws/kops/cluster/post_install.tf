resource "aws_autoscaling_schedule" "turn_off_master_at_night" {
  count = var.turn_off_cluster_at_night ? 1 : 0

  autoscaling_group_name = local.master_asg
  scheduled_action_name = format("%s-turn-off", local.master_asg)
  recurrence = var.turn_off_master_at_night_recurrence
  time_zone = var.turn_off_cluster_at_night_time_zone
  min_size = 0
  max_size = 1
  desired_capacity = 0

  depends_on = [ kops_cluster_updater.updater ]
}

resource "aws_autoscaling_schedule" "turn_off_nodes_at_night" {
  count = var.turn_off_cluster_at_night ? 1 : 0

  autoscaling_group_name = local.node_asg
  scheduled_action_name = format("%s-turn-off", local.node_asg)
  recurrence = var.turn_off_nodes_at_night_recurrence
  time_zone = var.turn_off_cluster_at_night_time_zone
  min_size = 0
  max_size = 3
  desired_capacity = 0

  depends_on = [ kops_cluster_updater.updater ]
}

resource "kubernetes_manifest" "cluster_issuer" {
  manifest = yamldecode(file("${path.module}/cluster-issuer.yaml"))

  depends_on = [ kops_cluster_updater.updater ]
}

resource "helm_release" "ack_iam_controller" {
  count = var.enable_ack_controller ? 1 : 0

  name       = local.ack_iam_controller_name
  repository = "oci://public.ecr.aws/aws-controllers-k8s"
  chart      = "iam-chart"
  version    = var.ack_iam_controller_version
  namespace = local.ack_namespace
  create_namespace = true

  set = [{
    name = "aws.region"
    value = local.aws_region
  }]

  depends_on = [ kops_cluster_updater.updater ]
}

resource "helm_release" "ack_s3_controller" {
  count = var.enable_ack_controller ? 1 : 0

  name       = local.ack_s3_controller_name
  repository = "oci://public.ecr.aws/aws-controllers-k8s"
  chart      = "s3-chart"
  version    = var.ack_s3_controller_version
  namespace = local.ack_namespace
  create_namespace = true

  set = [{
    name = "aws.region"
    value = local.aws_region
  }]

  depends_on = [ kops_cluster_updater.updater ]
}

resource "helm_release" "rabbitmq_operator" {
  count = var.enable_rabbitmq_operator ? 1 : 0

  name       = "rabbitmq-operator"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "rabbitmq-cluster-operator"
  version    = var.rabbitmq_operator_version
  namespace = "rabbitmq-system"
  create_namespace = true

  depends_on = [ kops_cluster_updater.updater ]
}

resource "helm_release" "prometheus_operator" {
  count = var.enable_prometheus_operator ? 1 : 0
  
  name = "prometheus-operator"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "kube-prometheus-stack"
  version = var.prometheus_operator_version
  namespace = "prometheus-operator"
  create_namespace = true

  depends_on = [ kops_cluster_updater.updater ]
}

resource "helm_release" "aws_load_balancer_controller" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0
  
  name = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart = "aws-load-balancer-controller"
  version = var.aws_load_balancer_controller_version
  namespace = "kube-system"
  create_namespace = false

  set = [{
    name = "clusterName"
    value = local.cluster_name
  }]

  depends_on = [ kops_cluster_updater.updater ]
}

resource "helm_release" "nginx_ingress_controller" {
  count = var.enable_nginx_ingress_controller ? 1 : 0
  
  name = "nginx-ingress-controller"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  version = var.nginx_ingress_controller_version
  namespace = "kube-system"
  create_namespace = false

  set = [{
    name = "controller.replicaCount"
    value = 3
  },{
    name = "controller.service.type"
    value = "LoadBalancer"
  },{
    name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  },{
    name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
    value = "instance"
  }]

  depends_on = [ kops_cluster_updater.updater ]
}

resource "helm_release" "external_dns" {
  count = var.enable_external_dns ? 1 : 0

  name = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart = "external-dns"
  version = var.external_dns_version
  namespace = "kube-system"
  create_namespace = false

  set = [{
    name = "provider.name"
    value = "aws"
  },{
    name = "env[0].name"
    value = "AWS_DEFAULT_REGION"
  },{
    name = "env[0].value"
    value = local.aws_region
  }]

  depends_on = [ kops_cluster_updater.updater ]
}

resource "helm_release" "argocd" {
  count = var.enable_argocd ? 1 : 0

  name = "argocd"	
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  version = var.argocd_version
  namespace = "argocd"
  create_namespace = true

  set = [{
    name = "global.domain"
    value = "argocd.${local.cluster_name}"
  },{
    name = "redis-ha.enabled"
    value = false
  },
  {
    name = "controller.replicas"
    value = 1
  },
  {
    name = "server.replicas"
    value = 1
  },
  {
    name = "repoServer.replicas"
    value = 1
  },
  {
    name = "applicationSet.replicas"
    value = 1
  },
  {
    name = "server.ingress.enabled"
    value = true
  },
  {
    name = "server.ingress.ingressClassName"
    value = "nginx"
  },
  {
    name = "server.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/backend-protocol"
    value : "HTTPS"
  },
  {
    name = "server.ingress.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname"
    value = "argocd.${local.cluster_name}"
  },
  {
    name = "server.ingress.annotations.cert-manager\\.io/cluster-issuer"
    value = "letsencrypt-prod"
  },
  {
    name = "server.ingress.tls"
    value = true
  }]

  depends_on = [ kops_cluster_updater.updater ]
}