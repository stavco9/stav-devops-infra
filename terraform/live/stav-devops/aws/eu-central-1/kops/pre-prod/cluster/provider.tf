terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kops = {
      source = "terraform-kops/kops"
      version = "1.32.0"
    }
  }

  backend "s3" {
    bucket = "882709358319-terraform-state"
    key    = "eu-central-1/kops/pre-prod/cluster/terraform.tfstate"
    dynamodb_table = "tf-state-lock"
    profile = "stav-devops"
    region = "us-east-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  profile = "stav-devops"
  region = "eu-central-1"
}

provider "kops" {
  state_store = "s3://882709358319-eu-central-1-stav-devops-kops-state-pre-prod"

  // optionally set up your cloud provider access config
  aws {
    profile = "stav-devops"
    region = "eu-central-1"
  }
}