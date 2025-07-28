module "sbd_ai" {
  source = "../../../../../../modules/aws/sbd-ai"

  environment = "test"
  create_bucket = true
}