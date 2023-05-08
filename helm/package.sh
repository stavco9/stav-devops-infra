echo "Packaging chart"
helm package flask-sample-app/helm-chart

echo "Indexing"
helm repo index --url https://stavco9.github.io/stav-devops-infra/helm/ .