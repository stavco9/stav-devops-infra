## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |
| <a name="requirement_kops"></a> [kops](#requirement\_kops) | 1.25.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.64.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.3.0 |
| <a name="provider_kops"></a> [kops](#provider\_kops) | 1.25.3 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.master_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.master_cert_validate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_iam_policy.external_dns_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.load_balancer_controller_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_route53_record.master_cert_validate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [kops_cluster.cluster](https://registry.terraform.io/providers/eddycharly/kops/1.25.3/docs/resources/cluster) | resource |
| [kops_cluster_updater.updater](https://registry.terraform.io/providers/eddycharly/kops/1.25.3/docs/resources/cluster_updater) | resource |
| [kops_instance_group.master-0](https://registry.terraform.io/providers/eddycharly/kops/1.25.3/docs/resources/instance_group) | resource |
| [kops_instance_group.node-0](https://registry.terraform.io/providers/eddycharly/kops/1.25.3/docs/resources/instance_group) | resource |
| [aws_caller_identity.account_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.dns_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [http_http.load_balancer_controller_policy](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [kops_kube_config.kube_config](https://registry.terraform.io/providers/eddycharly/kops/1.25.3/docs/data-sources/kube_config) | data source |
| [terraform_remote_state.kops_prerequisists](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.networking](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_kubeconfig"></a> [cluster\_kubeconfig](#output\_cluster\_kubeconfig) | n/a |
