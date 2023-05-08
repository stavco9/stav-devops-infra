output "cluster_kubeconfig" {
  value = {
    server = data.kops_kube_config.kube_config.server
    context = data.kops_kube_config.kube_config.context
    kube_user = data.kops_kube_config.kube_config.kube_user
    kube_password = data.kops_kube_config.kube_config.kube_password
  }

  sensitive = true
}