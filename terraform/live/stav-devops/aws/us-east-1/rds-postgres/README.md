## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.66.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rds_postgres"></a> [rds\_postgres](#module\_rds\_postgres) | ../../../../../modules/aws/postgres | n/a |

## Resources

| Name | Type |
|------|------|
| [random_password.db_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_caller_identity.curr_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.curr_partition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.curr_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [terraform_remote_state.networking](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_conn_string_secret_arn"></a> [db\_conn\_string\_secret\_arn](#output\_db\_conn\_string\_secret\_arn) | n/a |
| <a name="output_db_conn_string_secret_name"></a> [db\_conn\_string\_secret\_name](#output\_db\_conn\_string\_secret\_name) | n/a |
| <a name="output_db_conn_string_secret_policy_arn"></a> [db\_conn\_string\_secret\_policy\_arn](#output\_db\_conn\_string\_secret\_policy\_arn) | n/a |
| <a name="output_db_rds_sg_id"></a> [db\_rds\_sg\_id](#output\_db\_rds\_sg\_id) | n/a |
