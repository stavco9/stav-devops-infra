module "sbd_ai" {
  source = "../../../../../../modules/aws/sbd-ai"

  environment = "dev"
  create_bucket = true
}