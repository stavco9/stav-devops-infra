terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "882709358319-terraform-state"
    key            = "us-east-1/rds-postgres/terraform.tfstate"
    dynamodb_table = "tf-state-lock"
    profile        = "stav-devops"
    region         = "us-east-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  profile = "stav-devops"
  region  = "us-east-1"
}