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

    helm = {
      source = "hashicorp/helm"
      version = "3.0.2"
    }
  }
}