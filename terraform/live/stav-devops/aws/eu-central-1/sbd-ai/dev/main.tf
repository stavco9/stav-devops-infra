module "sbd_ai" {
  source = "../../../../../../modules/aws/sbd-ai"

  environment = "dev"
  project = "sbdai"
  create_bucket = true
  create_mongodb_cluster = true
  mongodb_iam_roles_access = [
    "arn:aws:iam::882709358319:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_eeb2dd0cf1e87c29",
    "arn:aws:iam::882709358319:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_PowerUserAccess_7ddb86f9991fed8f"
  ]
}