## kOps Cluster (AWS) — Terraform Module

This module provisions a Kubernetes cluster on AWS via kOps. It configures a public NLB for the Kubernetes API with ACM TLS, enables CoreDNS and kOps dns-controller for internal cluster records, and exposes toggles for IRSA, AWS Load Balancer Controller, Karpenter, and the Pod Identity Webhook. Rolling updates are handled by the kOps cluster updater resource.

### Providers
- aws ~> 6.0
- kops = 1.32.0
- http = 3.3.0

### What this module configures
- Public NLB for `api.<cluster>` with ACM certificate and Route53 DNS validation
- CoreDNS (`kube_dns { provider = "CoreDNS" }`)
- kOps dns-controller (enabled via `external_dns { provider = "dns-controller" }`) for internal cluster records (api, etcd, kops-controller)
- Optional IRSA using kOps Service Account Issuer Discovery written to S3
- Optional AWS Load Balancer Controller, Karpenter, and Pod Identity Webhook
- Metrics Server enabled; Calico CNI; topology DNS set to Public
- `kube_api_server.kubelet_preferred_address_types` prefers InternalDNS/InternalIP to avoid unresolved hostnames
- Rolling updates using `kops_cluster_updater` with validation gates

### Kubernetes Add-ons (optional)
- **ACK Controllers**: AWS Controllers for Kubernetes (IAM and S3) via Helm charts
  - IAM controller: manages AWS IAM resources from Kubernetes
  - S3 controller: manages S3 buckets and objects from Kubernetes
  - Requires IRSA with appropriate IAM policies
- **RabbitMQ Operator**: Bitnami RabbitMQ Cluster Operator for managing RabbitMQ clusters
  - Installs in `rabbitmq-system` namespace
  - Enables custom resources for RabbitMQ cluster management
- **Cert-Manager**: Automatic TLS certificate management
  - Installs Let's Encrypt cluster issuer for automatic certificate provisioning
  - Supports ACME protocol for certificate automation
- **Nginx Ingress Controller**: Alternative ingress controller for HTTP/HTTPS routing
  - Provides LoadBalancer service with AWS NLB integration
  - Configurable for internet-facing or internal load balancing
  - Works alongside AWS Load Balancer Controller
- **External-DNS**: Automatic DNS record management
  - Integrates with Route53 for automatic DNS record creation
  - Watches Ingress and Service resources for hostname management
  - Supports multiple DNS providers
- **Autoscaling Schedules**: Optional night-time cluster shutdown for cost optimization
  - Configurable timezone and recurrence patterns
  - Sets ASG desired capacity to 0 during off-hours

### Inputs (high level)
- `project`, `environment`
- `vpc_id`, `public_subnet_ids`, `private_subnet_ids`
- `kops_state_bucket`, `public_key_file_path`, `dns_zone`
- `kubernetes_version`, `ec2_instance_type`, `master_volume_size`, `node_volume_size`
- `kubernetes_master_policies`, `kubernetes_nodes_policies`, `cluster_admin_iam_roles`
- Feature toggles:
  - `enable_irsa` (bool)
  - `enable_aws_load_balancer_controller` (bool)
  - `enable_karpenter` (bool)
  - `enable_pod_identity_webhook` (bool)
  - `enable_ack_controller` (bool) - ACK IAM and S3 controllers
  - `enable_rabbitmq_operator` (bool) - RabbitMQ Cluster Operator
  - `enable_nginx_ingress_controller` (bool) - Nginx Ingress Controller
  - `enable_external_dns` (bool) - External-DNS for automatic DNS management
  - `turn_off_cluster_at_night` (bool) - Night-time shutdown schedules

### Outputs
- `cluster_kubeconfig` (sensitive): server/context/user details to access the cluster

### IRSA discovery bucket (important)
This module creates an S3 bucket for OIDC discovery when `enable_irsa = true`. kOps writes public discovery objects; the bucket must accept object ACLs and public-read writes. The module sets:
- `control_object_ownership = true`, `object_ownership = "ObjectWriter"`
- `block_public_acls = false`, `ignore_public_acls = false`, `block_public_policy = false`, `restrict_public_buckets = false`
You may also need to relax account-level “Block Public ACLs” for this specific bucket so kOps can upload `/.well-known/openid-configuration`.

### DNS responsibilities and ingress hostnames
- kOps dns-controller (enabled here via `external_dns { provider = "dns-controller" }`) creates internal cluster DNS records (api, etcd, kops-controller).
- Application hostnames are managed by external-dns, which watches your Ingress/Service resources and creates Route53 records that point to ALB/NLB provisioned by the AWS Load Balancer Controller or Nginx Ingress Controller.
  - Setup guide for external-dns with the AWS Load Balancer Controller: https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.1/guide/integrations/external_dns/
- **Ingress Controllers**: The module supports both AWS Load Balancer Controller (ALB/NLB) and Nginx Ingress Controller (NLB) for different use cases:
  - AWS Load Balancer Controller: Best for AWS-native load balancing with advanced features
  - Nginx Ingress Controller: Alternative for standard HTTP/HTTPS routing with NLB backend

### Usage sketch
Reference the module from your live stack and provide the networking, IAM, and feature flags:

```hcl
module "kops_cluster" {
  source = "../../../../modules/aws/kops//cluster"

  project              = var.project
  environment          = var.environment
  vpc_id               = var.vpc_id
  public_subnet_ids    = var.public_subnet_ids
  private_subnet_ids   = var.private_subnet_ids

  kops_state_bucket    = var.kops_state_bucket
  public_key_file_path = var.public_key_file_path
  dns_zone             = var.dns_zone

  kubernetes_master_policies = var.kubernetes_master_policies
  kubernetes_nodes_policies  = var.kubernetes_nodes_policies

  enable_irsa                         = true
  enable_aws_load_balancer_controller = true
  enable_karpenter                    = false
  enable_pod_identity_webhook         = false
  
  # Optional add-ons
  enable_ack_controller               = false
  enable_rabbitmq_operator            = false
  enable_nginx_ingress_controller     = false
  enable_external_dns                 = false
  turn_off_cluster_at_night           = false
}
```

After apply, validate cluster health and export kubeconfig as needed:

```bash
kops validate cluster --name <cluster-name> --state s3://<kops-state-bucket>
kops export kubeconfig --name <cluster-name> --state s3://<kops-state-bucket> --admin
```

### Add-on Configuration Notes
- **ACK Controllers**: When enabled, ensure the IAM policies (`ack_iam_controller_policy`, `ack_s3_controller_policy`) are provided and IRSA is enabled
- **RabbitMQ Operator**: Installs the operator only; RabbitMQ clusters are created separately using the operator's custom resources
- **Cert-Manager**: Automatically installs Let's Encrypt cluster issuer; requires DNS validation for certificate issuance
- **Nginx Ingress Controller**: Creates a LoadBalancer service with AWS NLB; configure annotations for internet-facing or internal access
- **External-DNS**: Requires Route53 permissions; automatically creates DNS records for Ingress and Service resources with appropriate annotations
- **Night-time Shutdown**: Use with caution in production; ensure applications can handle graceful shutdowns and restarts
