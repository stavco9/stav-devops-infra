# kOps Cluster - Pre-Production Environment

This Terraform stack deploys a Kubernetes cluster using kOps in the pre-production environment on AWS eu-central-1 region.

## Purpose

This live stack provisions a complete Kubernetes cluster with the following components:
- **kOps-managed Kubernetes cluster** (v1.32.0) with t3.small instances
- **CoreDNS** for internal cluster DNS resolution
- **kOps dns-controller** for internal cluster records (api, etcd, kops-controller)
- **IRSA (IAM Roles for Service Accounts)** with S3 discovery bucket
- **AWS Load Balancer Controller** for ALB/NLB provisioning
- **Karpenter** for node autoscaling
- **Pod Identity Webhook** for AWS Pod Identity
- **ACK Controllers** (IAM and S3) for managing AWS resources from Kubernetes
- **RabbitMQ Operator** for RabbitMQ cluster management
- **Cert-Manager** with Let's Encrypt cluster issuer for automatic TLS certificates
- **Nginx Ingress Controller** as alternative ingress solution with AWS NLB
- **External-DNS** for automatic Route53 DNS record management
- **Night-time shutdown schedules** for cost optimization (Asia/Jerusalem timezone)

## Prerequisites

1. **AWS SSO Login**: 
   ```bash
   aws sso login --profile stav-devops
   ```

2. **Required Remote States**:
   - `networking/pre-prod` - VPC, subnets, and networking infrastructure
   - `iam` - IAM roles and policies for Kubernetes components
   - `kops/pre-prod` - kOps state bucket and SSH keys

3. **Environment Variables** (for MongoDB Atlas integration):
   ```bash
   export TF_VAR_mongodbatlas_public_key="your_public_key"
   export TF_VAR_mongodbatlas_private_key="your_private_key"
   ```

## Usage

### Initial Setup

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Import existing resources** (if cluster already exists):
   ```bash
   # Import kOps state bucket if it exists
   terraform import "module.kops_cluster.module.oidc_provider_discovery_bucket.module.s3_bucket.aws_s3_bucket.this[0]" <bucket-name>
   ```

3. **Plan and Apply**:
   ```bash
   terraform plan
   terraform apply
   ```

### Cluster Management

**Validate cluster health**:
```bash
kops validate cluster --name k8s.stav-devops.eu-central-1.pre-prod.stavco9.com --state s3://882709358319-eu-central-1-stav-devops-kops-state-pre-prod
```

**Export kubeconfig**:
```bash
kops export kubeconfig --name k8s.stav-devops.eu-central-1.pre-prod.stavco9.com --state s3://882709358319-eu-central-1-stav-devops-kops-state-pre-prod --admin
```

**Check cluster status**:
```bash
kubectl get nodes
kubectl get pods --all-namespaces
```

## Configuration

### Feature Flags

All Kubernetes add-ons are enabled by default in this environment:
- `enable_irsa = true` - IAM Roles for Service Accounts
- `enable_aws_load_balancer_controller = true` - ALB/NLB provisioning
- `enable_karpenter = true` - Node autoscaling
- `enable_pod_identity_webhook = true` - AWS Pod Identity
- `enable_ack_controller = true` - ACK IAM and S3 controllers
- `enable_rabbitmq_operator = true` - RabbitMQ Cluster Operator
- `enable_nginx_ingress_controller = true` - Nginx Ingress Controller with AWS NLB
- `enable_external_dns = true` - External-DNS for automatic DNS management

### Cost Optimization

Night-time shutdown is enabled to reduce costs:
- **Nodes shutdown**: 22:00 (10 PM) daily
- **Master shutdown**: 23:00 (11 PM) daily
- **Timezone**: Asia/Jerusalem

### DNS Configuration

- **Internal cluster DNS**: CoreDNS + kOps dns-controller
- **External DNS zone**: `stavco9.com`
- **API endpoint**: `api.k8s.stav-devops.eu-central-1.pre-prod.stavco9.com`
- **Application DNS**: External-DNS automatically creates Route53 records for Ingress resources
- **Certificate management**: Cert-Manager with Let's Encrypt for automatic TLS certificates

### Ingress Configuration

The cluster supports multiple ingress controllers:
- **AWS Load Balancer Controller**: For AWS-native ALB/NLB with advanced features
- **Nginx Ingress Controller**: Alternative solution with AWS NLB backend
- **ArgoCD**: Configured to use Nginx Ingress with automatic DNS and TLS certificates

## IRSA Discovery Bucket

The cluster creates an S3 bucket for OIDC discovery when IRSA is enabled. This bucket:
- Accepts object ACLs and public-read writes
- Stores `/.well-known/openid-configuration` for OIDC provider discovery
- Must have relaxed public ACL settings for kOps to function properly

## Troubleshooting

### Common Issues

1. **Master instance replacement on every apply**:
   ```bash
   # Skip rolling update to prevent instance replacement
   kops rolling-update cluster --name k8s.stav-devops.eu-central-1.pre-prod.stavco9.com --state s3://882709358319-eu-central-1-stav-devops-kops-state-pre-prod --skip
   ```

2. **DNS resolution issues**:
   - Verify CoreDNS pods are running: `kubectl get pods -n kube-system -l k8s-app=kube-dns`
   - Check kube-dns service: `kubectl get svc -n kube-system kube-dns`

3. **IRSA/OIDC issues**:
   - Verify OIDC discovery bucket exists and is accessible
   - Check IAM roles have correct trust policies

### Useful Commands

```bash
# Check kOps cluster status
kops get cluster --state s3://882709358319-eu-central-1-stav-devops-kops-state-pre-prod

# View cluster configuration
kops get cluster --state s3://882709358319-eu-central-1-stav-devops-kops-state-pre-prod -o yaml

# Check instance groups
kops get ig --state s3://882709358319-eu-central-1-stav-devops-kops-state-pre-prod

# View logs for specific components
kubectl logs -n kube-system deployment/aws-load-balancer-controller
kubectl logs -n kube-system deployment/karpenter
kubectl logs -n kube-system deployment/nginx-ingress-controller
kubectl logs -n kube-system deployment/external-dns
kubectl logs -n cert-manager deployment/cert-manager
```

## Outputs

- `cluster_kubeconfig` - Kubernetes configuration for cluster access

