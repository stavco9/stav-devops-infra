echo "Packaging chart"
helm package flask-sample-app/helm-chart

echo "Indexing"
helm repo index .