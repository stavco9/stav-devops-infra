output "kops_state_bucket_name" {
  value = module.kops_state_bucket.kops_bucket_name
}

output "public_key_path" {
  value = module.kops_state_bucket.public_key_path
}

#output "cluster_kubeconfig" {
#  
#}