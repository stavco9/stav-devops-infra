output "kops_bucket_name" {
  value = local.kops_state_bucket
}

output "public_key_path" {
  value = "${abspath(path.root)}/public_key.pem"
}