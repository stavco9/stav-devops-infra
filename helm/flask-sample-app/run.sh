CHART_NAME="stav-poc"
CHART_PATH="./helm-chart"
CHART_VERSION=0.1.0
K8S_NAMESPACE="flask-sample-dev"
MODE="install"

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
