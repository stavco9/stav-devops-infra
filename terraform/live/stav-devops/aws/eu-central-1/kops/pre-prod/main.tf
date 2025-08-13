locals {
  project = "stav-devops"
  environment = "pre-prod"
}

module "kops_state_bucket"{
    source = "../../../../../../modules/aws/kops"

    project = local.project
    environment = local.environment
}