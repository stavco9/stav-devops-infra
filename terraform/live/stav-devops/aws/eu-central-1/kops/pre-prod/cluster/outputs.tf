output "cluster_kubeconfig" {
  value = module.kops_cluster.cluster_kubeconfig

  sensitive = true
}

output "cluster_name" {
  value = module.kops_cluster.cluster_name
}

output "irsa_discovery_bucket_url" {
  value = module.kops_cluster.irsa_discovery_bucket_url
}

output "irsa_oidc_provider_arn" {
  value = module.kops_cluster.irsa_oidc_provider_arn
}