module "networking"{
    source = "../../../../../modules/aws/networking"

    vpc_name = "vpc-stav-devops"
    vpc_cidr = "10.0.0.0/23"
    project = "stav-devops"
    environment = "dev"
    private_subnets = [ "10.0.0.0/26", "10.0.0.64/26" ]
    public_subnets = [ "10.0.1.0/26", "10.0.1.64/26" ]
    
    enable_nat_gateway = true
    single_nat_gateway = true
}