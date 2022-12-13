repo=${1:?usage $0 \{ my-harbor-proxy/docker-io| docker.io \}}

echo "${repo}" > ,REPO

echo "=== HELM ADD BITNAMI AND UPDATE ..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
echo ""
echo "=== READY"
