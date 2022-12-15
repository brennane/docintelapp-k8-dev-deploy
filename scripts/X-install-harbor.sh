#
# proxy+ClusterIP (internal to cluster only)
#

# VMWare's harbor charts
# helm repo add bitnami https://charts.bitnami.com/bitnami ; helm repo update

## this installs harbor at "harbor.harbor-system.svc.cluster.local" with the
## following to access.


helm install harbor bitnami/harbor --version 16.0.4 \
    --create-namespace -n harbor-system \
    --set exposureType=proxy --set service.type=ClusterIP \
    --set service.clusterIP=10.43.20.20 \
    --set adminPassword=abc123 

#
# now add a docker.io proxy and local registry for docintel builds!
#
# kubectl port-forward --namespace harbor-system svc/harbor 8443:443 
#
