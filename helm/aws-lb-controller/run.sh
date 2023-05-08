CHART_URL="https://aws.github.io/eks-charts"
CHART_ALIAS="eks"
CHART_NAME="aws-load-balancer-controller"
CHART_PATH="${CHART_ALIAS}/${CHART_NAME}"
CHART_VERSION=1.5.2
K8S_NAMESPACE="kube-system"
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
