CHART_URL="https://kokuwaio.github.io/helm-charts"
CHART_ALIAS="kokuwa"
CHART_NAME="fluentd-elasticsearch"
CHART_PATH="${CHART_ALIAS}/${CHART_NAME}"
CHART_VERSION=13.9.0
K8S_NAMESPACE="logging"
MODE="install"

echo "Check if chart is already downloaded"
helm show chart ${CHART_PATH} --version ${CHART_VERSION} > /dev/null

if [ $? -ne 0 ]; then
    echo "Downloading chart"
    helm repo add $CHART_ALIAS $CHART_URL
    helm repo update 
fi

echo "Check if chart already exists"
helm status $CHART_NAME -n $K8S_NAMESPACE > /dev/null

if [ $? -eq 0 ]; then
    echo "Chart exists, upgrading"
    MODE="upgrade"
else
    echo "Chart does not exists. Installing"
fi

helm $MODE $CHART_NAME $CHART_PATH --version $CHART_VERSION -n $K8S_NAMESPACE --create-namespace -f values.yaml

if [ $? -eq 0 ]; then
    echo "Chart applied successfully !!!!"

    exit 0
else
    echo "Chart has been failed..."

    exit 1
fi
