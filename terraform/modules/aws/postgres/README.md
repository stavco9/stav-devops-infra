## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_postgres-db"></a> [postgres-db](#module\_postgres-db) | terraform-aws-modules/rds/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.db_read_secret_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_secretsmanager_secret.db_connection_string](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.db_connection_string](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.postgres_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.postgres_sg_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [random_shuffle.az](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/shuffle) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_db_subnet_group.db_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/db_subnet_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | n/a | `string` | `"owna"` | no |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | n/a | `string` | `""` | no |
| <a name="input_db_subnet_group"></a> [db\_subnet\_group](#input\_db\_subnet\_group) | n/a | `string` | n/a | yes |
| <a name="input_db_user"></a> [db\_user](#input\_db\_user) | n/a | `string` | `""` | no |
| <a name="input_db_version"></a> [db\_version](#input\_db\_version) | n/a | `string` | `"14"` | no |
| <a name="input_env"></a> [env](#input\_env) | n/a | `any` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `"owna"` | no |
| <a name="input_rds_access_cidrs"></a> [rds\_access\_cidrs](#input\_rds\_access\_cidrs) | n/a | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_address"></a> [db\_address](#output\_db\_address) | n/a |
| <a name="output_db_conn_string_secret_arn"></a> [db\_conn\_string\_secret\_arn](#output\_db\_conn\_string\_secret\_arn) | n/a |
| <a name="output_db_conn_string_secret_name"></a> [db\_conn\_string\_secret\_name](#output\_db\_conn\_string\_secret\_name) | n/a |
| <a name="output_db_conn_string_secret_policy_arn"></a> [db\_conn\_string\_secret\_policy\_arn](#output\_db\_conn\_string\_secret\_policy\_arn) | n/a |
| <a name="output_sg_id"></a> [sg\_id](#output\_sg\_id) | n/a |
