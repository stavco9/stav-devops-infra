Direcrory of Helm charts that installed on the stav-devops kubernetes cluster

Prerequisists:
1. Login to AWS account using CLI:
   1.1 aws configure sso --profile stav-devops
   1.2 SSO Url -> https://d-9067bcdfe7.awsapps.com/start
   1.3 SSO Region -> us-east-1
   1.4 SSO Account -> 882709358319
   1.5 SSO Role -> AdministratorAccess
   1.6 SSO Output -> json
2. Get kops kubeconfig
   2.1 kops export kubeconfig --admin
   2.2 sed -i -e 's/api-k8s-stav-devops-stavc-uloip0-f9280beae6f673f5.elb.us-east-1.amazonaws.com/api.k8s.stav-devops.stavco9.com/g' ~/.kube/config

Process:
1. Go to the chart folder you want to install
2. Update the values.yaml and run ./run.sh

Package self hosted charts:
1. For self hosted charts (Like flask-sample-app), run the script ./package.sh in the root helm folder
2. The script is packaging the charts you want to package, updates the index.yaml file and commits the change to the helm-repo branch which exports a GitHub page
3. The helm charts then can be installed from the Github page by running the commands:
   3.1 helm repo add stav-devops-helm https://stavco9.github.io/stav-devops-infra/helm
   3.2 helm upgrade --install <your-release-name> stav-devops-help/flask-sample --version 0.1.0 -n <your-namespace> --create-namespace -f values.yaml