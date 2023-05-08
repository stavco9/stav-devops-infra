#helm repo add kokuwa https://kokuwaio.github.io/helm-charts
#helm repo update
#helm install fluentd kokuwa/fluentd-elasticsearch -n logging --create-namespace -f fluentd-values.yaml
helm upgrade fluentd kokuwa/fluentd-elasticsearch -n logging -f fluentd-values.yaml