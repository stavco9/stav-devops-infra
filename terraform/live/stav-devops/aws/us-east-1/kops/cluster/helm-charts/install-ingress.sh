
#helm repo add nginx-stable https://helm.nginx.com/stable
#helm repo add jetstack https://charts.jetstack.io
#helm repo add eks https://aws.github.io/eks-charts
#helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
#helm repo update
#helm install external-dns external-dns/external-dns --namespace external-dns --create-namespace 
#helm install cert-manager --namespace cert-manager --version v1.11.1 jetstack/cert-manager --create-namespace -f cert-manager-values.yaml
#helm install aws-load-balancer-controller eks/aws-load-balancer-controller -f aws-load-balancer-controller-values.yaml -n kube-system
#helm install nginx-ingress nginx-stable/nginx-ingress --version 0.15.2 -n ingress --create-namespace
helm upgrade nginx-ingress nginx-stable/nginx-ingress --version 0.15.2 -n ingress -f nginx-ingress-values.yaml
#helm upgrade external-dns external-dns/external-dns --namespace external-dns -f external-dns-values.yaml
#kubectl apply -f cluster-issuer.yaml