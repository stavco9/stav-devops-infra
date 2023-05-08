locals {
  vpc_name = format("%s-%s", var.vpc_name, var.gcp_region)

  subnets = [ for i, subnet in var.subnets : {
   subnet_name = format("%s%d", var.vpc_name, i + 1)
   subnet_ip = subnet
   subnet_region = var.gcp_region
   subnet_private_access = true
  }]
}