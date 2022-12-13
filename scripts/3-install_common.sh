#
# Namespace, if needed.
#
echo "=== NAMESPACE ..."
kubectl apply -f common/namespace.yaml

#
# These services are all independent of each other.
#
echo ""
echo "=== RABBITMQ INSTALL ..."
kubectl apply -f common/rabbitmq.yaml
echo ""
echo "=== POSTGRESQL INSTALL ..."
kubectl apply -f common/postgresql.yaml
echo ""
echo "=== SOLR INSTALL ..."
kubectl apply -f common/solr.yaml
echo ""
echo "=== SYNAPSE INSTALL ..."
kubectl apply -f common/synapse.yaml

#
# WAITING FOR SERVICES
#
echo ""
echo "=== RABBITMQ ROLLOUT ..."
kubectl -n docintel rollout status statefulset/rabbitmq
echo ""
echo "=== POSTGRESQL ROLLOUT ..."
kubectl -n docintel rollout status statefulset/postgresql
echo ""
echo "=== SOLR ROLLOUT ..."
kubectl -n docintel rollout status statefulset/solr
echo ""
echo "=== SYNPASE ROLLOUT ..."
kubectl -n docintel rollout status deploy/synapse-cortex
echo ""

echo ""
echo "=== POSTGRESQL INIT ..."

echo ""
echo "=== SOLR INIT ..."


