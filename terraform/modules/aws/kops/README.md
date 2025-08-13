## kOps Prerequisites — Terraform Module

This module creates the S3 state bucket used by kOps and generates an SSH keypair (written as local files) for cluster access.

### Providers
- aws ~> 6.0
- local 2.4.0
- tls 4.0.4

### Module(s)
- terraform-aws-modules/s3-bucket/aws

### Resources
- tls_private_key.ssh_key
- local_file.private_key
- local_file.public_key
- aws_caller_identity.account_id (data)

### Inputs
- `project` (string)
- `environment` (string)

### Outputs
- `kops_bucket_name`: S3 bucket name created for kOps state
- `public_key_path`: path to the generated SSH public key

### Notes
- The bucket name is derived from account/region/project/environment and intended to be unique and stable.
- If the bucket already exists, import it into Terraform state before apply to avoid recreate attempts:
  ```bash
  terraform import "module.kops_state_bucket.module.s3_bucket.aws_s3_bucket.this[0]" <existing-bucket-name>
  ```
