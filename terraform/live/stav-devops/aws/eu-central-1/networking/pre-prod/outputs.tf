output "vpc_id" {
    value = module.networking.vpc_id
}

output "private_subnet_ids" {
    value = module.networking.private_subnet_ids
}

output "public_subnet_ids" {
    value = module.networking.public_subnet_ids
}

output "vpc_cidr" {
    value = module.networking.vpc_cidr
}

output "subnet_azs" {
    value = module.networking.subnet_azs
}

output "private_db_subnet_group" {
  value = module.networking.private_db_subnet_group
}

output "public_db_subnet_group" {
  value = module.networking.public_db_subnet_group
}

output "vpc_endpoints" {
  value = module.networking.vpc_endpoints
}