data "aws_availability_zones" "all_az" {
  state = "available"
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.all_az.names, 0, 2)
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform = "true"
    Name = var.vpc_name
  }

  private_subnet_tags = {
      Name = format("%s-private", var.vpc_name)
  }

  public_subnet_tags = {
      Name = format("%s-public", var.vpc_name)
  }
}