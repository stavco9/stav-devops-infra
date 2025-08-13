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

### Outputs
- `cluster_kubeconfig` (sensitive): server/context/user details to access the cluster

### IRSA discovery bucket (important)
This module creates an S3 bucket for OIDC discovery when `enable_irsa = true`. kOps writes public discovery objects; the bucket must accept object ACLs and public-read writes. The module sets:
- `control_object_ownership = true`, `object_ownership = "ObjectWriter"`
- `block_public_acls = false`, `ignore_public_acls = false`, `block_public_policy = false`, `restrict_public_buckets = false`
You may also need to relax account-level “Block Public ACLs” for this specific bucket so kOps can upload `/.well-known/openid-configuration`.

### DNS responsibilities and ingress hostnames
- kOps dns-controller (enabled here via `external_dns { provider = "dns-controller" }`) creates internal cluster DNS records (api, etcd, kops-controller).
- Application hostnames are managed by external-dns, which watches your Ingress/Service resources and creates Route53 records that point to ALB/NLB provisioned by the AWS Load Balancer Controller.
  - Setup guide for external-dns with the AWS Load Balancer Controller: https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.1/guide/integrations/external_dns/

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
}
```

After apply, validate cluster health and export kubeconfig as needed:

```bash
kops validate cluster --name <cluster-name> --state s3://<kops-state-bucket>
kops export kubeconfig --name <cluster-name> --state s3://<kops-state-bucket> --admin
```
