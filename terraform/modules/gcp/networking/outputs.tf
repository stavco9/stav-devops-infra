output "vpc_id" {
    value = module.networking.network_id
}

output "subnet_ids" {
    value = module.networking.subnets_ids
}