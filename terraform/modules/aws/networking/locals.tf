locals{
    common_tags = {
        Terraform = "true"
        Name = var.vpc_name
        Project = var.project
        Environment = var.environment
    }
}