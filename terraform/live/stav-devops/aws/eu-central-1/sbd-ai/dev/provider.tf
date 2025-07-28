terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "~> 1.0"
    }
  }

  backend "s3" {
    bucket = "882709358319-terraform-state"
    key    = "eu-central-1/sbd-ai/dev/terraform.tfstate"
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

provider "mongodbatlas" {
  public_key = var.mongodbatlas_public_key
  private_key = var.mongodbatlas_private_key
}