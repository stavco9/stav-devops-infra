output "kops_bucket_name" {
  value = local.s3_kops_state
}

output "public_key_path" {
  value = "${abspath(path.root)}/public_key.pem"
}