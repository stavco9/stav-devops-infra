terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    kops = {
      source = "eddycharly/kops"
      version = "1.25.3"
    }
  }

  backend "s3" {
    bucket = "882709358319-terraform-state"
    key    = "us-east-1/kops/cluster/terraform.tfstate"
    dynamodb_table = "tf-state-lock"
    profile = "stav-devops"
    region = "us-east-1"
  }
}

provider "kops" {
  state_store = "s3://882709358319-kops-state"

  // optionally set up your cloud provider access config
  aws {
    profile = "stav-devops"
    region = "us-east-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  profile = "stav-devops"
  region = "us-east-1"
}