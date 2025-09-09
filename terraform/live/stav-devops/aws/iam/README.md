# IAM Roles and Policies - Stav DevOps Infrastructure

This Terraform stack manages IAM roles, policies, and users required for the Stav DevOps Kubernetes infrastructure on AWS.

## Purpose

This stack provisions the following IAM resources:
- **ECR Pusher User**: Dedicated IAM user for pushing container images to ECR
- **Kubernetes Service Policies**: IAM policies for various Kubernetes components
- **ACK Controller Policies**: Policies for AWS Controllers for Kubernetes
- **External-DNS Policy**: Route53 permissions for automatic DNS management
- **Karpenter Policy**: EC2 and ASG permissions for node autoscaling

## Prerequisites

1. **AWS SSO Login**: 
   ```bash
   aws sso login --profile stav-devops
   ```

2. **Required Environment Variables**:
   ```bash
   export AWS_PROFILE=stav-devops
   ```

## Usage

### Initial Setup

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Plan and Apply**:
   ```bash
   terraform plan
   terraform apply
   ```

## IAM Resources

### ECR Pusher User

- **User**: `Stav-DevOps-ECR-Pusher`
- **Purpose**: Dedicated user for pushing container images to Amazon ECR
- **Policy**: `AmazonEC2ContainerRegistryFullAccess`
- **Credentials**: Stored in AWS Secrets Manager for secure access

### Kubernetes Component Policies

#### AWS Load Balancer Controller Policy
- **Name**: `AWSLoadBalancerControllerIAMPolicy`
- **Source**: `aws-load-balancer-permissions.json`
- **Permissions**: 
  - EC2 instance and security group management
  - ELB/ALB/NLB creation and management
  - VPC and subnet access
  - IAM role management for service accounts

#### External-DNS Policy
- **Name**: `AllowExternalDNSUpdates`
- **Source**: `route53-permissions.json`
- **Permissions**:
  - Route53 hosted zone management
  - DNS record creation and updates
  - Resource tagging for external-dns

#### Karpenter Policy
- **Name**: `KubernetesKarpenterPolicy`
- **Source**: `karpenter-permissions.json`
- **Permissions**:
  - EC2 instance management
  - Auto Scaling Group operations
  - Launch template management
  - Subnet and security group access

### ACK Controller Policies

#### ACK IAM Controller Policy
- **Name**: `ACKControllerManagementIAMPolicy`
- **Source**: GitHub repository (recommended-inline-policy)
- **Permissions**: IAM resource management from Kubernetes

#### ACK S3 Controller Policy
- **Name**: `ACKControllerS3Policy`
- **Source**: GitHub repository (recommended-inline-policy)
- **Permissions**: S3 bucket and object management from Kubernetes

## Policy Files

### aws-load-balancer-permissions.json
Contains comprehensive permissions for the AWS Load Balancer Controller:
- EC2 instance and security group management
- ELB/ALB/NLB operations
- VPC and subnet access
- IAM role and policy management

### route53-permissions.json
Contains Route53 permissions for External-DNS:
- Hosted zone management
- DNS record operations
- Resource tagging

### karpenter-permissions.json
Contains EC2 and ASG permissions for Karpenter:
- Instance management
- Auto Scaling Group operations
- Launch template management

## Outputs

The stack provides the following outputs for use by other Terraform modules:

- `kubernetes_master_policies`: List of IAM policy ARNs for master nodes
- `kubernetes_nodes_policies`: List of IAM policy ARNs for worker nodes
- `aws_load_balancer_controller_policy`: ARN of the AWS Load Balancer Controller policy
- `external_dns_policy`: ARN of the External-DNS policy
- `kubernetes_karpenter_policy`: ARN of the Karpenter policy
- `ack_iam_controller_policy`: ARN of the ACK IAM controller policy
- `ack_s3_controller_policy`: ARN of the ACK S3 controller policy

## Security Considerations

1. **Least Privilege**: All policies follow the principle of least privilege
2. **Resource Scoping**: Policies are scoped to specific resources where possible
3. **Conditional Access**: Some policies include conditions for additional security
4. **Credential Management**: ECR pusher credentials are stored securely in Secrets Manager

## Integration with Kubernetes

These IAM policies are used by the kOps cluster module through IRSA (IAM Roles for Service Accounts):

1. **Service Account Annotations**: Kubernetes service accounts are annotated with IAM role ARNs
2. **OIDC Provider**: kOps creates an OIDC identity provider for trust relationships
3. **Automatic Credential Injection**: AWS SDK automatically assumes the IAM role

## Troubleshooting

### Common Issues

1. **Policy Attachment Failures**:
   ```bash
   # Check if policies exist
   aws iam list-policies --query 'Policies[?PolicyName==`AWSLoadBalancerControllerIAMPolicy`]'
   ```

2. **ECR Access Issues**:
   ```bash
   # Retrieve ECR credentials from Secrets Manager
   aws secretsmanager get-secret-value --secret-id Stav-DevOps-ECR-Pusher
   ```

3. **External-DNS Permission Issues**:
   ```bash
   # Verify Route53 permissions
   aws route53 list-hosted-zones
   ```

### Useful Commands

```bash
# List all IAM policies created by this stack
aws iam list-policies --query 'Policies[?contains(PolicyName, `AWSLoadBalancerControllerIAMPolicy`) || contains(PolicyName, `AllowExternalDNSUpdates`) || contains(PolicyName, `KubernetesKarpenterPolicy`) || contains(PolicyName, `ACKControllerManagementIAMPolicy`) || contains(PolicyName, `ACKControllerS3Policy`)]'

# Check ECR pusher user
aws iam get-user --user-name Stav-DevOps-ECR-Pusher

# Verify policy attachments
aws iam list-attached-user-policies --user-name Stav-DevOps-ECR-Pusher
```

## Dependencies

This stack has no dependencies and can be applied independently. However, the outputs are consumed by:
- `kops/pre-prod/cluster` - Uses policy ARNs for IRSA configuration
- CI/CD pipelines - Uses ECR pusher credentials for container image publishing

## Maintenance

### Policy Updates

When updating policies:
1. Modify the JSON policy files
2. Run `terraform plan` to see changes
3. Apply changes with `terraform apply`
4. Update dependent stacks if necessary

### Credential Rotation

ECR pusher credentials can be rotated by:
1. Deleting the access key: `terraform destroy -target=aws_iam_access_key.ecr_pusher`
2. Re-applying: `terraform apply`
3. Updating CI/CD systems with new credentials from Secrets Manager
