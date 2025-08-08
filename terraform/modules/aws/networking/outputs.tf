output "vpc_id" {
    value = module.vpc.vpc_id
}

output "vpc_cidr" {
    value = module.vpc.vpc_cidr_block
}

output "private_subnet_ids" {
    value = module.vpc.private_subnets
}

output "public_subnet_ids" {
    value = module.vpc.public_subnets
}

output "subnet_azs" {
    value = module.vpc.azs
}

output "private_db_subnet_group" {
  value = aws_db_subnet_group.rds_vpc_private.name
}

output "public_db_subnet_group" {
  value = aws_db_subnet_group.rds_vpc_public.name
}

output "vpc_endpoints" {
  value = module.vpc_endpoints.endpoints
}