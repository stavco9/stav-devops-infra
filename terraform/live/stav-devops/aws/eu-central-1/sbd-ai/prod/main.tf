module "sbd_ai" {
  source = "../../../../../../modules/aws/sbd-ai"

  environment = "prod"
  create_bucket = true
}