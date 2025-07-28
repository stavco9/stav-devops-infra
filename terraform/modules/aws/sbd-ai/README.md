# SBD AI Terraform Module

## Overview

The SBD AI Terraform module is designed to provision and manage AWS infrastructure for the SBD AI video processing platform. This module creates a secure S3 bucket for storing video files with proper security configurations and versioning enabled.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    SBD AI Module                          │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐   │
│  │              S3 Bucket                             │   │
│  │  ┌─────────────────────────────────────────────┐   │   │
│  │  │ • Private Access Only                      │   │   │
│  │  │ • Versioning Enabled                      │   │   │
│  │  │ • Public Access Blocked                   │   │   │
│  │  │ • Encryption at Rest                      │   │   │
│  │  └─────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Features

- **Secure S3 Bucket**: Creates a private S3 bucket with all public access blocked
- **Versioning**: Enables versioning for data protection and recovery
- **Naming Convention**: Follows a standardized naming pattern: `{account-id}-{region}-sbdai-videos-{environment}`
- **Resource Tagging**: Comprehensive tagging for cost tracking and resource management
- **Conditional Creation**: Optional bucket creation based on `create_bucket` variable
- **Multi-Region Support**: Automatically detects and uses the current AWS region

## 🚀 Quick Start

### Basic Usage

```hcl
module "sbd_ai" {
  source = "terraform-aws-modules/sbd-ai/aws"

  environment = "dev"
  create_bucket = true
}
```

### Advanced Usage

```hcl
module "sbd_ai" {
  source = "../../../../../../modules/aws/sbd-ai"

  environment = "production"
  create_bucket = true
}
```

## 📝 Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `environment` | `string` | **Required** | Environment name (e.g., "dev", "staging", "production") |
| `create_bucket` | `bool` | `true` | Whether to create the S3 bucket |

### Variable Details

#### `environment`
- **Type**: `string`
- **Required**: Yes
- **Description**: Specifies the deployment environment
- **Example Values**: `"dev"`, `"staging"`, `"production"`

#### `create_bucket`
- **Type**: `bool`
- **Default**: `true`
- **Description**: Controls whether the S3 bucket should be created
- **Use Cases**: Set to `false` when you want to reference an existing bucket

## 📤 Outputs

| Output | Type | Description |
|--------|------|-------------|
| `sbd_ai_videos_bucket` | `string` | The name of the created S3 bucket |

### Output Details

#### `sbd_ai_videos_bucket`
- **Type**: `string`
- **Description**: Returns the complete bucket name following the naming convention
- **Format**: `{account-id}-{region}-sbdai-videos-{environment}`
- **Example**: `882709358319-eu-central-1-sbdai-videos-dev`

## 🔧 Configuration

### S3 Bucket Security Features

The module creates an S3 bucket with the following security configurations:

- **Public Access Blocked**: All public access is blocked by default
- **Versioning Enabled**: File versioning is enabled for data protection
- **Private ACL**: Bucket is configured with private access only
- **Encryption**: Server-side encryption is enabled by default

### Resource Tagging

All resources are tagged with the following metadata:

```hcl
tags = {
  Name        = "{bucket-name}"
  Environment = "{environment}"
  Region      = "{current-region}"
  Project     = "sbd-ai"
  Owner       = "stav-devops"
  ManagedBy   = "terraform"
}
```

## 🌍 Multi-Environment Deployment

### Development Environment

```hcl
module "sbd_ai_dev" {
  source = "../../../../../../modules/aws/sbd-ai"

  environment = "dev"
  create_bucket = true
}
```

### Staging Environment

```hcl
module "sbd_ai_staging" {
  source = "../../../../../../modules/aws/sbd-ai"

  environment = "staging"
  create_bucket = true
}
```

### Production Environment

```hcl
module "sbd_ai_prod" {
  source = "../../../../../../modules/aws/sbd-ai"

  environment = "production"
  create_bucket = true
}
```

## 🔍 Usage Examples

### Example 1: Basic Development Setup

```hcl
# main.tf
module "sbd_ai" {
  source = "../../../../../../modules/aws/sbd-ai"

  environment = "dev"
  create_bucket = true
}

# outputs.tf
output "sbd_ai_videos_bucket" {
  value = module.sbd_ai.sbd_ai_videos_bucket
}
```

### Example 2: Conditional Bucket Creation

```hcl
module "sbd_ai" {
  source = "../../../../../../modules/aws/sbd-ai"

  environment = "dev"
  create_bucket = var.create_video_bucket
}
```

## 🛠️ Prerequisites

- Terraform >= 1.0
- AWS Provider >= 6.0
- AWS credentials configured
- Appropriate AWS permissions for S3 bucket creation

## 📋 Required AWS Permissions

The following AWS permissions are required to use this module:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:PutBucketVersioning",
        "s3:PutBucketPublicAccessBlock",
        "s3:PutBucketPolicy",
        "s3:GetBucketPolicy",
        "s3:GetBucketVersioning",
        "s3:GetBucketPublicAccessBlock"
      ],
      "Resource": "arn:aws:s3:::*-sbdai-videos-*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": "arn:aws:s3:::*"
    }
  ]
}
```

## 🔄 State Management

### Backend Configuration

The module uses S3 backend for state management:

```hcl
terraform {
  backend "s3" {
    bucket         = "882709358319-terraform-state"
    key            = "eu-central-1/sbd-ai/{environment}/terraform.tfstate"
    dynamodb_table = "tf-state-lock"
    profile        = "stav-devops"
    region         = "us-east-1"
  }
}
```

## 🚨 Important Notes

1. **Bucket Naming**: Bucket names are globally unique. The module automatically generates unique names based on account ID, region, and environment.

2. **Region Detection**: The module automatically detects the current AWS region using the `aws_region` data source.

3. **Security**: All buckets are created with maximum security settings by default.

4. **Cost Considerations**: S3 versioning may increase storage costs. Monitor usage in production environments.

## 🔧 Troubleshooting

### Common Issues

1. **Bucket Already Exists**: Ensure bucket names are unique across all AWS accounts
2. **Permission Denied**: Verify AWS credentials and permissions
3. **Region Mismatch**: Ensure the AWS provider region matches your intended deployment region

### Debug Commands

```bash
# Validate Terraform configuration
terraform validate

# Plan deployment
terraform plan

# Apply changes
terraform apply

# Show current state
terraform show
```

## 📚 Related Documentation

- [AWS S3 Bucket Documentation](https://docs.aws.amazon.com/s3/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform S3 Backend](https://www.terraform.io/language/settings/backends/s3)

## 🤝 Contributing

When contributing to this module:

1. Follow the existing code style
2. Add appropriate tests
3. Update documentation for any new features
4. Ensure backward compatibility

## 📄 License

This module is part of the SBD AI infrastructure and follows the project's licensing terms.

---

**Last Updated**: $(date)
**Module Version**: 1.0.0
**Terraform Version**: >= 1.0
**AWS Provider Version**: >= 6.0 