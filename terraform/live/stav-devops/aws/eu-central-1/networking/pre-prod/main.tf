module "networking"{
    source = "../../../../../../modules/aws/networking"

    vpc_cidr = "10.0.0.0/23"

    project = "stav-devops"
    environment = "pre-prod"
    private_subnets = [ "10.0.0.0/26", "10.0.0.64/26", "10.0.0.128/26" ]
    public_subnets = [ "10.0.1.0/26", "10.0.1.64/26", "10.0.1.128/26" ]

    single_nat_gateway = true
    enable_nat_gateway = true
    enable_s3_endpoint = true
}