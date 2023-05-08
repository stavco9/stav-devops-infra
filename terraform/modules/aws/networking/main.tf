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

  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Terraform = "true"
    Project = var.project
    Environment = var.environment
  })

  private_subnet_tags = {
      Name = format("%s-private", var.vpc_name)
      Access = "private"
  }

  public_subnet_tags = {
      Name = format("%s-public", var.vpc_name)
      Access = "public"
  }
}

resource "aws_db_subnet_group" "rds_vpc_private" {
  name       = format("%s-private", var.vpc_name)
  subnet_ids = module.vpc.private_subnets

  tags = merge(local.common_tags, {
    Name = format("%s-private", var.vpc_name)
    Access = "private"
  })
}

resource "aws_db_subnet_group" "rds_vpc_public" {
  name       = format("%s-public", var.vpc_name)
  subnet_ids = module.vpc.public_subnets

  tags = merge(local.common_tags, {
    Name = format("%s-public", var.vpc_name)
    Access = "public"
  })
}