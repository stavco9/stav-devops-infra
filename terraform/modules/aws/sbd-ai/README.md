# SBD AI Terraform Module

## Overview

The SBD AI Terraform module is designed to provision and manage AWS infrastructure for the SBD AI video processing platform. This module creates a secure S3 bucket for storing video files and a MongoDB Atlas cluster for database needs, both with proper security configurations and versioning enabled.

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
│                                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           MongoDB Atlas Cluster                   │   │
│  │  ┌─────────────────────────────────────────────┐   │   │
│  │  │ • AWS Provider (TENANT)                    │   │   │
│  │  │ • M0 Instance Size                         │   │   │
│  │  │ • Automatic Backups                        │   │   │
│  │  │ • Private Network Access                   │   │   │
│  │  └─────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Features

- **Secure S3 Bucket**: Creates a private S3 bucket with all public access blocked
- **MongoDB Atlas Cluster**: Provisions a MongoDB Atlas cluster with AWS provider
- **Versioning**: Enables versioning for data protection and recovery
- **Naming Convention**: Follows a standardized naming pattern for both resources
- **Resource Tagging**: Comprehensive tagging for cost tracking and resource management
- **Conditional Creation**: Optional resource creation based on variables
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
  create_mongodb_cluster = true
}
```

## 📝 Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `environment` | `string` | **Required** | Environment name (e.g., "dev", "staging", "production") |
| `create_bucket` | `bool` | `true` | Whether to create the S3 bucket |
| `create_mongodb_cluster` | `bool` | `true` | Whether to create the MongoDB Atlas cluster |
| `mongodb_iam_roles_access` | `list(string)` | `[]` | List of IAM role ARNs for MongoDB database user access |

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

#### `create_mongodb_cluster`
- **Type**: `bool`
- **Default**: `true`
- **Description**: Controls whether the MongoDB Atlas cluster should be created
- **Use Cases**: Set to `false` when you want to reference an existing cluster

#### `mongodb_iam_roles_access`
- **Type**: `list(string)`
- **Default**: `[]`
- **Description**: List of AWS IAM role ARNs that will be granted database access
- **Use Cases**: Provide IAM role ARNs for applications that need database access
- **Example**: `["arn:aws:iam::123456789012:role/my-app-role"]`

## 📤 Outputs

| Output | Type | Description |
|--------|------|-------------|
| `sbd_ai_videos_bucket` | `string` | The name of the created S3 bucket |
| `sbd_ai_mongodb_cluster` | `string` | The name of the created MongoDB Atlas cluster |
| `sbd_ai_mongodb_connection_string` | `object` | MongoDB Atlas cluster connection strings |

### Output Details

#### `sbd_ai_videos_bucket`
- **Type**: `string`
- **Description**: Returns the complete bucket name following the naming convention
- **Format**: `{account-id}-{region}-sbdai-videos-{environment}`
- **Example**: `882709358319-eu-central-1-sbdai-videos-dev`

#### `sbd_ai_mongodb_cluster`
- **Type**: `string`
- **Description**: Returns the complete MongoDB Atlas cluster name following the naming convention
- **Format**: `sbdai-mongodb-{environment}`
- **Example**: `sbdai-mongodb-dev`

#### `sbd_ai_mongodb_connection_string`
- **Type**: `object`
- **Description**: Returns the MongoDB Atlas cluster connection strings for different access methods
- **Contains**: Standard and private connection strings for database access

## 🔧 Configuration

### S3 Bucket Security Features

The module creates an S3 bucket with the following security configurations:

- **Public Access Blocked**: All public access is blocked by default
- **Versioning Enabled**: File versioning is enabled for data protection
- **Private ACL**: Bucket is configured with private access only
- **Encryption**: Server-side encryption is enabled by default

### MongoDB Atlas Cluster Features

The module creates a MongoDB Atlas cluster with the following configurations:

- **Provider**: AWS (TENANT)
- **Instance Size**: M0 (Free tier)
- **Region**: Automatically uses the current AWS region
- **Backup**: Automatic backups enabled
- **Network Access**: Private network access configured
- **IAM Authentication**: Supports AWS IAM role-based database access
- **Database Users**: Creates database users for each provided IAM role ARN
- **IP Access Control**: Configures IP access lists (open for dev, restricted for other environments)

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
  create_mongodb_cluster = true
}
```

### Staging Environment

```hcl
module "sbd_ai_staging" {
  source = "../../../../../../modules/aws/sbd-ai"

  environment = "staging"
  create_bucket = true
  create_mongodb_cluster = true
}
```

### Production Environment

```hcl
module "sbd_ai_prod" {
  source = "../../../../../../modules/aws/sbd-ai"

  environment = "production"
  create_bucket = true
  create_mongodb_cluster = true
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

### Example 2: Conditional Resource Creation

```hcl
module "sbd_ai" {
  source = "../../../../../../modules/aws/sbd-ai"

  environment = "dev"
  create_bucket = var.create_video_bucket
  create_mongodb_cluster = var.create_mongodb_cluster
}
```

### Example 3: S3 Bucket Only

```hcl
module "sbd_ai" {
  source = "../../../../../../modules/aws/sbd-ai"

  environment = "dev"
  create_bucket = true
  create_mongodb_cluster = false
}
```

### Example 4: MongoDB Cluster Only

```hcl
module "sbd_ai" {
  source = "../../../../../../modules/aws/sbd-ai"

  environment = "dev"
  create_bucket = false
  create_mongodb_cluster = true
}
```

### Example 5: MongoDB Cluster with IAM Role Access

```hcl
module "sbd_ai" {
  source = "../../../../../../modules/aws/sbd-ai"

  environment = "dev"
  create_bucket = true
  create_mongodb_cluster = true
  mongodb_iam_roles_access = [
    "arn:aws:iam::123456789012:role/my-application-role",
    "arn:aws:iam::123456789012:role/my-backend-role"
  ]
}
```

## 🛠️ Prerequisites

- Terraform >= 1.0
- AWS Provider >= 6.0
- MongoDB Atlas Provider >= 1.0
- AWS credentials configured
- MongoDB Atlas API keys configured
- Appropriate AWS permissions for S3 bucket creation
- MongoDB Atlas organization access

## 📋 Required Permissions

### AWS Permissions

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

### MongoDB Atlas Permissions

The following MongoDB Atlas permissions are required:

- **Organization Owner** or **Project Owner** role
- **Project Data Access Admin** for cluster management
- **Project Owner** for project creation and deletion

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

2. **MongoDB Atlas**: The cluster uses AWS as the cloud provider (TENANT) and M0 instance size (free tier).

3. **Region Detection**: The module automatically detects the current AWS region using the `aws_region` data source.

4. **Security**: All resources are created with maximum security settings by default.

5. **Cost Considerations**: 
   - S3 versioning may increase storage costs
   - MongoDB Atlas M0 tier is free but has limitations
   - Monitor usage in production environments

6. **MongoDB Atlas API Keys**: Ensure your API keys have the necessary permissions for project and cluster management.

7. **IAM Authentication**: The module supports AWS IAM role-based authentication for MongoDB Atlas. Each IAM role ARN provided in `mongodb_iam_roles_access` will create a corresponding database user.

8. **IP Access Control**: Development environments have open IP access (0.0.0.0/0), while other environments have restricted access. Configure appropriate IP access lists for production use.

9. **Database Users**: Database users are created with `readWriteAnyDatabase` role. Customize roles as needed for your application requirements.

## 🔧 Troubleshooting

### Common Issues

1. **Bucket Already Exists**: Ensure bucket names are unique across all AWS accounts
2. **Permission Denied**: Verify AWS credentials and permissions
3. **Region Mismatch**: Ensure the AWS provider region matches your intended deployment region
4. **MongoDB Atlas Authentication**: Verify MongoDB Atlas API keys and permissions
5. **MongoDB Atlas Provider**: Ensure you're using `mongodb/mongodbatlas` provider source
6. **IAM Role Access**: Verify that provided IAM role ARNs exist and have appropriate permissions
7. **Database User Creation**: Ensure MongoDB Atlas API keys have permissions to create database users
8. **IP Access List**: Check that IP access lists are properly configured for your environment

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
- [MongoDB Atlas Documentation](https://docs.atlas.mongodb.com/)
- [MongoDB Atlas IAM Authentication](https://docs.atlas.mongodb.com/security-aws-iam/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform MongoDB Atlas Provider](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs)
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