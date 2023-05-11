locals {
    db_name = "golangexersize"
    vpc_name = "vpc-stav-devops"
    subnet_group = format("%s-%s", local.vpc_name, "public")

    common_tags = {
        Terraform = true
        Project = "stav-devops"
        Environment = "dev"
    }
}

data "aws_availability_zones" "all_az" {
  state = "available"
}

data "aws_vpc" "project_vpc" {
    tags = {
        Name = local.vpc_name
    }
}

data "http" "my_ip" {
    url = "https://api.ipify.org/?format=json"
}