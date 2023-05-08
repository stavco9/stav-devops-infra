#helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
#helm repo add grafana https://grafana.github.io/helm-charts
#helm repo update
#helm install prometheus prometheus-community/prometheus -n monitoring --create-namespace
#helm install grafana grafana/grafana -n monitoring --create-namespace
#helm upgrade prometheus prometheus-community/prometheus -n monitoring
helm upgrade grafana grafana/grafana -f grafana-values.yaml -n monitoring