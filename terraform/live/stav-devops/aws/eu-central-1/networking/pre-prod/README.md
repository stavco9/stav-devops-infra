# Pre-Prod Networking Infrastructure

This Terraform module deploys the networking infrastructure for the pre-production environment in the `eu-central-1` region.

## Prerequisites

### AWS Authentication

Before running this module, you must authenticate with AWS using SSO:

1. **Login to AWS SSO:**
   ```bash
   aws sso login --profile stav-devops
   ```

2. **Verify Authentication:**
   ```bash
   aws sts get-caller-identity --profile stav-devops
   ```

3. **Verify Account ID:**
   The output should show account ID: `882709358319`

### Required Tools

- Terraform >= 1.0
- AWS CLI >= 2.0
- AWS SSO configured with `stav-devops` profile

## Configuration

### Current Settings

This module is configured for the pre-production environment with the following specifications:

- **Region:** `eu-central-1`
- **VPC CIDR:** `10.0.0.0/23` (512 IP addresses)
- **Environment:** `pre-prod`
- **Project:** `stav-devops`
- **Availability Zones:** 3 (automatically determined from subnet count)

### Subnet Configuration

#### Private Subnets (3 subnets)
- `10.0.0.0/26` (64 IPs each)
- `10.0.0.64/26`
- `10.0.0.128/26`

#### Public Subnets (3 subnets)
- `10.0.1.0/26` (64 IPs each)
- `10.0.1.64/26`
- `10.0.1.128/26`

### Network Features

- **NAT Gateway:** Disabled (cost optimization)
- **Single NAT Gateway:** Disabled
- **S3 Endpoint:** Enabled (free gateway endpoint)
- **DNS Support:** Enabled
- **DNS Hostnames:** Enabled

## Usage

### Initial Setup

1. **Navigate to the module directory:**
   ```bash
   cd sbd_ai/stav-devops-infra/terraform/live/stav-devops/aws/eu-central-1/networking/pre-prod
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Plan the deployment:**
   ```bash
   terraform plan
   ```

4. **Apply the configuration:**
   ```bash
   terraform apply
   ```

### State Management

The Terraform state is stored remotely in S3:
- **Bucket:** `882709358319-terraform-state`
- **Key:** `eu-central-1/networking/pre-prod/terraform.tfstate`
- **Lock Table:** `tf-state-lock`
- **Region:** `us-east-1`

### Destroying Infrastructure

⚠️ **Warning:** This will permanently delete all networking resources.

```bash
terraform destroy
```

## Outputs

The module provides the following outputs:

| Output | Description |
|--------|-------------|
| `vpc_id` | The ID of the created VPC |
| `private_subnet_ids` | List of private subnet IDs |
| `public_subnet_ids` | List of public subnet IDs |
| `vpc_cidr` | The CIDR block of the VPC |
| `subnet_azs` | Availability zones used for subnets |
| `private_db_subnet_group` | Private DB subnet group name |
| `public_db_subnet_group` | Public DB subnet group name |
| `vpc_endpoints` | VPC endpoints configuration |

### Example Output Usage

```bash
# Get VPC ID
terraform output vpc_id

# Get all outputs
terraform output
```

## Cost Considerations

### Free Resources
- VPC creation and management
- Subnet creation
- Route tables
- Network ACLs
- DB subnet groups
- S3 Gateway Endpoint

### Cost Optimization Features
- **NAT Gateway disabled:** Saves ~$45/month per AZ
- **S3 Gateway Endpoint:** Free alternative to VPC Endpoint
- **Efficient CIDR allocation:** Optimized subnet sizing

## Security

### Network Security
- Private subnets have no direct internet access
- Public subnets have internet access via Internet Gateway
- Network ACLs provide additional security layers
- All resources are tagged for cost tracking and management

### IAM Requirements
- AWS SSO profile with appropriate permissions
- Terraform state bucket access
- VPC and networking resource creation permissions

## Troubleshooting

### Common Issues

1. **Authentication Errors:**
   ```bash
   # Re-authenticate with SSO
   aws sso login --profile stav-devops
   ```

2. **State Lock Issues:**
   ```bash
   # Force unlock (use with caution)
   terraform force-unlock <lock-id>
   ```

3. **CIDR Conflicts:**
   - Ensure VPC CIDR doesn't overlap with existing VPCs
   - Verify subnet CIDRs are within VPC CIDR range

### Support

For issues or questions:
1. Check Terraform logs for detailed error messages
2. Verify AWS credentials and permissions
3. Ensure all prerequisites are met

## Related Documentation

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform VPC Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
