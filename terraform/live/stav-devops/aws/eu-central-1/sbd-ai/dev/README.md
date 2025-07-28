# SBD AI Dev Environment

## 🚀 Quick Start

This directory contains the Terraform configuration for the SBD AI development environment in AWS `eu-central-1` region.

## 📋 Prerequisites

Before running this Terraform configuration, ensure you have:

- **Terraform** >= 1.0 installed
- **AWS CLI** configured with SSO
- **MongoDB Atlas** account with API keys
- **Administrator Access** to AWS account `882709358319`

## 🔐 Authentication Setup

### 1. AWS Authentication

You need to authenticate with AWS using SSO:

```bash
# Login to AWS SSO with the stav-devops profile
aws sso login --profile stav-devops
```

**Important Notes:**
- Make sure you're logging into account number: **`882709358319`**
- Ensure you have **AdministratorAccess** permissions
- The profile `stav-devops` should be configured in your `~/.aws/config`

### 2. MongoDB Atlas Authentication

Set the MongoDB Atlas API keys as environment variables:

```bash
# Set MongoDB Atlas Public Key
export TF_VAR_mongodbatlas_public_key="your_mongodb_atlas_public_key"

# Set MongoDB Atlas Private Key  
export TF_VAR_mongodbatlas_private_key="your_mongodb_atlas_private_key"
```

**For Windows PowerShell:**
```powershell
# Set MongoDB Atlas Public Key
$env:TF_VAR_mongodbatlas_public_key="your_mongodb_atlas_public_key"

# Set MongoDB Atlas Private Key
$env:TF_VAR_mongodbatlas_private_key="your_mongodb_atlas_private_key"
```

**For Windows Command Prompt:**
```cmd
# Set MongoDB Atlas Public Key
set TF_VAR_mongodbatlas_public_key=your_mongodb_atlas_public_key

# Set MongoDB Atlas Private Key
set TF_VAR_mongodbatlas_private_key=your_mongodb_atlas_private_key
```

## 🏗️ Infrastructure Overview

This environment creates:

- **S3 Bucket**: Secure storage for video files
- **MongoDB Atlas Cluster**: Database for application data
- **Resource Tagging**: Comprehensive tagging for cost tracking

### Resource Naming Convention

- **S3 Bucket**: `{account-id}-{region}-sbdai-videos-{environment}`
- **MongoDB Cluster**: `sbdai-mongodb-{environment}`
- **Example**: `882709358319-eu-central-1-sbdai-videos-dev`

## 🚀 Deployment Steps

### Step 1: Initialize Terraform

```bash
# Navigate to the dev directory
cd sbd_ai/stav-devops-infra/terraform/live/stav-devops/aws/eu-central-1/sbd-ai/dev

# Initialize Terraform
terraform init
```

### Step 2: Test Database Connection (Optional)

After deployment, you can test the MongoDB Atlas connection:

```powershell
# Test the database connection using AWS IAM authentication
.\test_db_connection.ps1
```

This script will:
- Automatically detect your AWS credential type (SSO or regular)
- Extract the appropriate temporary credentials
- Connect to the MongoDB Atlas cluster using AWS IAM authentication
- Provide feedback on connection success or failure

### Step 3: Plan the Deployment

```bash
# Review the planned changes
terraform plan
```

### Step 4: Apply the Configuration

```bash
# Deploy the infrastructure
terraform apply
```

### Step 5: Verify Deployment

```bash
# Check the outputs
terraform output

# Show current state
terraform show
```

## 🔧 Configuration

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `TF_VAR_mongodbatlas_public_key` | MongoDB Atlas Public API Key | Yes |
| `TF_VAR_mongodbatlas_private_key` | MongoDB Atlas Private API Key | Yes |

### AWS Configuration

The configuration uses:
- **Profile**: `stav-devops`
- **Region**: `eu-central-1` (Frankfurt)
- **Account**: `882709358319`

### Backend Configuration

Terraform state is stored in S3:
- **Bucket**: `882709358319-terraform-state`
- **Key**: `eu-central-1/sbd-ai/dev/terraform.tfstate`
- **Region**: `us-east-1`

## 📊 Resources Created

### S3 Bucket
- **Purpose**: Secure storage for video files
- **Security**: Private access only, versioning enabled
- **Encryption**: Server-side encryption enabled

### MongoDB Atlas Cluster
- **Provider**: AWS (TENANT)
- **Instance Size**: M0 (Free tier)
- **Region**: eu-central-1
- **Backup**: Automatic backups enabled

## 📁 Project Files

### Core Terraform Files
- `main.tf` - Main Terraform configuration
- `provider.tf` - Provider configuration
- `vars.tf` - Variable definitions
- `outputs.tf` - Output definitions

### Utility Scripts
- `test_db_connection.ps1` - PowerShell script for testing MongoDB Atlas connection using AWS IAM authentication
  - **Features**: Automatic SSO detection, smart credential handling, error checking
  - **Usage**: Run after deployment to verify database connectivity
  - **Requirements**: AWS CLI, MongoDB Shell, valid AWS credentials

## 🔍 Troubleshooting

### Common Issues

#### 1. AWS Authentication Error
```bash
Error: No valid credential sources found for AWS Provider
```

**Solution:**
```bash
# Ensure you're logged in with the correct profile
aws sso login --profile stav-devops

# Verify the profile configuration
aws sts get-caller-identity --profile stav-devops
```

#### 2. MongoDB Database Connection Testing

A PowerShell script is provided to test the MongoDB Atlas connection using AWS IAM authentication:

```powershell
# Test MongoDB connection with AWS IAM authentication
.\test_db_connection.ps1
```

**Script Features:**
- **Automatic SSO Detection**: Detects whether you're using AWS SSO or regular AWS credentials
- **Smart Credential Handling**: Uses `aws configure export-credentials` for SSO profiles and `aws sts get-session-token` for regular profiles
- **Error Handling**: Includes proper error checking and user feedback
- **MongoDB Atlas Integration**: Connects to the MongoDB Atlas cluster using AWS IAM authentication

**Prerequisites for Database Testing:**
- AWS CLI configured with the `stav-devops` profile
- MongoDB Shell (`mongosh`) installed
- Active AWS SSO session or valid AWS credentials

**Troubleshooting Database Connection:**
```powershell
# Check if AWS credentials are working
aws sts get-caller-identity --profile stav-devops

# Verify MongoDB Atlas cluster is accessible
aws configure export-credentials --profile stav-devops --format json
```

#### 2. MongoDB Atlas Authentication Error
```bash
Error: 401 (request failed): You are not authorized for this resource
```

**Solution:**
- Verify your MongoDB Atlas API keys are correct
- Ensure the API keys have the necessary permissions
- Check that the environment variables are set correctly

#### 3. Provider Version Conflicts
```bash
Error: Failed to query available provider packages
```

**Solution:**
```bash
# Remove cached provider data
rm -rf .terraform .terraform.lock.hcl

# Reinitialize Terraform
terraform init
```

### Debug Commands

```bash
# Check AWS credentials
aws sts get-caller-identity --profile stav-devops

# Verify environment variables
echo $TF_VAR_mongodbatlas_public_key
echo $TF_VAR_mongodbatlas_private_key

# Validate Terraform configuration
terraform validate

# Show provider configuration
terraform providers
```

## 🧹 Cleanup

### Destroy Infrastructure

```bash
# Destroy all resources
terraform destroy
```

**⚠️ Warning**: This will permanently delete all resources created by this configuration.

### Remove Environment Variables

```bash
# Unset MongoDB Atlas variables
unset TF_VAR_mongodbatlas_public_key
unset TF_VAR_mongodbatlas_private_key
```

## 📚 Related Documentation

- [AWS SSO Documentation](https://docs.aws.amazon.com/singlesignon/latest/userguide/)
- [MongoDB Atlas API Documentation](https://docs.atlas.mongodb.com/api/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform MongoDB Atlas Provider](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs)

## 🔐 Security Notes

- **S3 Bucket**: All public access is blocked by default
- **MongoDB Atlas**: Uses private network access
- **State Management**: Terraform state is encrypted in S3
- **API Keys**: Store MongoDB Atlas keys securely, never commit them to version control

## 📞 Support

For issues with this environment:

1. Check the troubleshooting section above
2. Verify AWS and MongoDB Atlas credentials
3. Review Terraform logs for detailed error messages
4. Contact the DevOps team for additional support

---

**Environment**: Development  
**Region**: eu-central-1 (Frankfurt)  
**Account**: 882709358319  
**Last Updated**: $(date)  
**Terraform Version**: >= 1.0 