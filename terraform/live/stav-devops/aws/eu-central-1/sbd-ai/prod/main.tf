module "sbd_ai" {
  source = "../../../../../../modules/aws/sbd-ai"

  environment = "prod"
  project = "sbdai"
  create_bucket = true
  create_mongodb_cluster = false
}