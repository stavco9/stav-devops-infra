## kOps Prerequisites — Live Stack (pre-prod, eu-central-1)

This live stack provisions the prerequisites for the kOps cluster:
- S3 state bucket used by kOps (`kops_state_bucket_name`)
- SSH keypair artifacts (private/public key files on local disk)

### Layout
- `provider.tf`: providers and remote state backend, if any
- `main.tf`: invokes `modules/aws/kops` prereq module
- `outputs.tf`: exposes the state bucket name and public key path

### Usage
```bash
terraform init -upgrade
terraform plan
terraform apply
```

If the S3 bucket already exists, import it before `apply` to avoid recreation:
```bash
terraform import "module.kops_state_bucket.module.s3_bucket.aws_s3_bucket.this[0]" \
  882709358319-eu-central-1-stav-devops-kops-state-pre-prod
```

### Outputs
- `kops_state_bucket_name`: S3 bucket to pass into the cluster live stack
- `public_key_path`: path to the generated SSH public key


