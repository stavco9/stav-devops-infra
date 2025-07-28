#aws sso login --profile stav-devops
Remove-Item terra* -Force -Recurse
terraform init
terraform plan