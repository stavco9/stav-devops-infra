module "networking" {
    source  = "terraform-google-modules/network/google"
    version = "~> 4.0"

    project_id = var.project_name

    network_name = local.vpc_name
    routing_mode = "REGIONAL"

    subnets = local.subnets
}