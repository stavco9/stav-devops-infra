module "networking"{
    source = "../../../../../modules/gcp/networking"

    vpc_name = "vpc-stav-devops"
    project_name = "stav-devops"
    gcp_region = "us-central1"
    subnets = [ "10.0.0.0/26", "10.0.0.64/26" ]
}