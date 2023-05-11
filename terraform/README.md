Direcrory of terraform modules that installed on the stav-devops AWS Account

Prerequisists:
1. Login to AWS account using CLI:
   1.1 aws configure sso --profile stav-devops
   1.2 SSO Url -> https://d-9067bcdfe7.awsapps.com/start
   1.3 SSO Region -> us-east-1
   1.4 SSO Account -> 882709358319
   1.5 SSO Role -> AdministratorAccess
   1.6 SSO Output -> json

Process:
1. Go to the helm module you want to install under live folder
2. Run:
   2.1 rm -rf .terra*
   2.2 terraform init
   2.3 terraform plan / terraform apply
   2.4 Adding TF documentation by running: docker run --rm --volume "$(pwd):/terraform-docs" -u $(id -u) quay.io/terraform-docs/terraform-docs:0.16.0 markdown /terraform-docs > README.md 