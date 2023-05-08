terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.41.0"
    }
  }
}
# Configure the AWS Provider
provider "google" {
  project = "stav-devops"
  region = "us-central1"
}