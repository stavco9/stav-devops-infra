## kOps Cluster — Live Stack (pre-prod, eu-central-1)

This live stack instantiates the kOps cluster module for the `stav-devops` project in `eu-central-1` (environment: `pre-prod`). It wires networking, IAM policies, state bucket, and feature flags for the cluster.

### Layout
- `provider.tf`: providers, remote state for networking/iam/kops prerequisites
- `main.tf`: module call to `modules/aws/kops//cluster`
- `outputs.tf`: selected outputs (kops state bucket name, public key path, etc.)

### Prerequisites
- AWS SSO profile available and logged in
  - `aws sso login --profile stav-devops`
  - set `AWS_PROFILE=stav-devops`
- Remote states exist and are accessible (networking/iam/kops prereqs)
- kOps state bucket exists (or has been imported into Terraform state)

### First-time setup / import
If the kOps state bucket already exists, import it in the prereq stack before applying here. Example nested resource to import:

```bash
# In the kops prereq stack directory (not this folder)
terraform import "module.kops_state_bucket.module.s3_bucket.aws_s3_bucket.this[0]" \
  882709358319-eu-central-1-stav-devops-kops-state-pre-prod
```

### Apply
```bash
terraform init -upgrade
terraform plan
terraform apply
```

The apply will:
- Create/validate ACM cert for `api.<cluster>`
- Stand up/roll the kOps `cluster` and `instance_group`s
- Run `kops_cluster_updater` to validate and roll instances as needed

### Export kubeconfig / validate
```bash
# Validate cluster health
kops validate cluster --name k8s.stav-devops.eu-central-1.pre-prod.stavco9.com \
  --state s3://$(terraform output -raw kops_state_bucket_name)

# Export kubeconfig (alternative to module data source)
kops export kubeconfig --name k8s.stav-devops.eu-central-1.pre-prod.stavco9.com \
  --state s3://$(terraform output -raw kops_state_bucket_name) --admin
```

### Feature flags (set in module call)
- `enable_irsa`: enables kOps Service Account Issuer Discovery backed by S3
- `enable_aws_load_balancer_controller`: installs AWS LB Controller
- `enable_karpenter`: toggles Karpenter support
- `enable_pod_identity_webhook`: toggles AWS pod identity webhook

### IRSA discovery bucket (important)
The kOps OIDC discovery is stored in an S3 bucket and needs to accept `public-read` ACLs on objects. The module configures:
- `control_object_ownership = true`, `object_ownership = ObjectWriter`
- `block_public_acls = false`, `ignore_public_acls = false`, `block_public_policy = false`, `restrict_public_buckets = false`
If the account-level "Block Public ACLs" is enforced, kOps writes will fail (e.g., `AccessControlListNotSupported`). Relax that control for this bucket.

### DNS responsibilities
- kOps dns-controller (enabled by the module) creates internal cluster records (api, etcd, kops-controller)
- CoreDNS is enabled for in-cluster name resolution
- Application hostnames are created by `external-dns` pointing Ingress hosts to ALB/NLB created by AWS Load Balancer Controller. See: https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.1/guide/integrations/external_dns/

### Useful operational commands
```bash
# Rolling update status (non-destructive plan)
kops rolling-update cluster --name k8s.stav-devops.eu-central-1.pre-prod.stavco9.com \
  --state s3://$(terraform output -raw kops_state_bucket_name)

# Force a roll when needed
kops rolling-update cluster --yes --name k8s.stav-devops.eu-central-1.pre-prod.stavco9.com \
  --state s3://$(terraform output -raw kops_state_bucket_name)
```

### Troubleshooting quick refs
- Node won't join, `nodeup` logs show `kops-controller DNS not setup yet (placeholder 203.0.113.123)`:
  - Ensure dns-controller is running and has Route53 permissions; wait for Route53 records to exist, then restart nodeup.
- Pods cannot resolve DNS:
  - Ensure CoreDNS `kube-dns` Service exists; if blocked by webhooks, bring AWS LB Controller up or set its webhook failurePolicy to Ignore temporarily.
- Metrics Server timeouts to kubelet (10250):
  - Allow TCP/10250 between node security groups; ensure Calico overlay ports (UDP/4789 and/or protocol 4) are allowed between nodes.
- IRSA/OIDC errors writing discovery objects to S3:
  - Relax bucket + account public ACL settings per above.


