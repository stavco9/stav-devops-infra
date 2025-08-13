output "cluster_kubeconfig" {
  value = module.kops_cluster.cluster_kubeconfig

  sensitive = true
}