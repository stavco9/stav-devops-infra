CHART_NAME="namespace-on-boarding"
CHART_PATH="./helm-chart"
CHART_VERSION=0.1.0
MODE="install"
K8S_NAMESPACE="kube-system"
ENVIRONMENT=$1

echo "Check if chart already exists"
helm status $CHART_NAME-$ENVIRONMENT -n $K8S_NAMESPACE > /dev/null

if [ $? -eq 0 ]; then
    echo "Chart exists, upgrading"
    MODE="upgrade"
else
    echo "Chart does not exists. Installing"
fi

helm $MODE $CHART_NAME-$ENVIRONMENT $CHART_PATH --version $CHART_VERSION -n $K8S_NAMESPACE -f values-${ENVIRONMENT}.yaml

if [ $? -eq 0 ]; then
    echo "Chart applied successfully !!!!"

    exit 0
else
    echo "Chart has been failed..."

    exit 1
fi
