output "cluster_kubeconfig" {
  value = {
    server = data.kops_kube_config.kube_config.server
    context = data.kops_kube_config.kube_config.context
    kube_user = data.kops_kube_config.kube_config.kube_user
    kube_password = data.kops_kube_config.kube_config.kube_password
  }

  sensitive = true
}

output "cluster_name" {
  value = local.cluster_name
}

output "irsa_discovery_bucket_url" {
  value = module.oidc_provider_discovery_bucket.s3_bucket_bucket_regional_domain_name
}

output "irsa_oidc_provider_arn" {
  value = "arn:aws:iam::${local.aws_account_id}:oidc-provider/${module.oidc_provider_discovery_bucket.s3_bucket_bucket_regional_domain_name}"
}