branch=$(cat static/DOCINTEL_BRANCH)

#  nc -w 0 -zv postgresql.docintel.svc.cluster.local 5432
postgres_user=postgres
postgres_pass=$(kubectl get secret --namespace docintel postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
postgres_db=docintel
postgres_port=5432
postgres_svc=postgresql.docintel.svc.cluster.local 
postgres_svc_headless=postgresql-hl.docintel.svc.cluster.local 
postgres_ip=$(kubectl -n docintel get svc postgresql -o jsonpath='{.spec.clusterIP}')

rabbit_user=user
rabbit_pass=$(kubectl get secret --namespace docintel rabbitmq -o jsonpath="{.data.rabbitmq-password}" | base64 -d)
rabbit_cookie=$(kubectl get secret --namespace docintel rabbitmq -o jsonpath="{.data.rabbitmq-erlang-cookie}" | base64 -d)
rabbit_svc=rabbitmq.docintel.svc.cluster.local 
rabbit_svc_headless=rabbitmq-headless.docintel.svc.cluster.local 
rabbit_ip=$(kubectl -n docintel get svc rabbitmq -o jsonpath='{.spec.clusterIP}')
rabbit_guest_user="$rabbit_user"
rabbit_guest_pass="$rabbit_pass"

# solr_user=admin
# solr_pass=$(kubectl get secret --namespace docintel solr -o jsonpath="{.data.solr-password}" | base64 -d)
solr_svc=solr.docintel.svc.cluster.local
solr_svc_headless=solr-headless.docintel.svc.cluster.local
solr_ip=$(kubectl -n docintel get svc solr -o jsonpath='{.spec.clusterIP}')
solr_url="http://${solr_svc}:8983"

synapse_svc=synapse-cortex.docintel.svc.cluster.local
synapse_svc_headless=synapse-cortex-headless.docintel.svc.cluster.local
synapse_url="https://${synapse_svc}:4443"
synapse_user="root"
synapse_pass=$(kubectl get secret --namespace docintel synapse -o jsonpath="{.data.cortex-auth-password}" | base64 -d)

# solr_zk_svc=solr-zookeeper.docintel.svc.cluster.local

conffolder="./app-config"
mkdir -p $conffolder

curl https://raw.githubusercontent.com/docintelapp/DocIntel/${branch}/conf/appsettings.json.example -o $conffolder/appsettings.json.orig
curl https://raw.githubusercontent.com/docintelapp/DocIntel/${branch}/conf/appsettings.json.example -o $conffolder/appsettings.json
curl https://raw.githubusercontent.com/docintelapp/DocIntel/${branch}/conf/nlog.config.example -o $conffolder/nlog.config

# POSTGRES SETTINGS
sed -i.bck "s~_POSTGRES_USER_~${postgres_user}~g" $conffolder/appsettings.json
sed -i.bck "s~_POSTGRES_PW_~${postgres_pass}~g" $conffolder/appsettings.json
sed -i.bck "s~_POSTGRES_DB_~${postgres_db}~g" $conffolder/appsettings.json
sed -i.bck "s~_POSTGRES_PORT_~${postgres_port}~g" $conffolder/appsettings.json
sed -i.bck "s~_POSTGRES_HOST_~${postgres_svc}~g" $conffolder/appsettings.json

# RABBIT-MQ SETTINGS
sed -i.bck "s~_RABBITMQ_HOST_~${rabbit_svc_headless}~g" $conffolder/appsettings.json
sed -i.bck "s~_RABBITMQ_VHOST_~/~g" $conffolder/appsettings.json
sed -i.bck "s~_RABBITMQ_USER_~${rabbit_guest_user}~g" $conffolder/appsettings.json
sed -i.bck "s~_RABBITMQ_PW_~${rabbit_guest_pass}~g" $conffolder/appsettings.json

# SOLR SETTINGS
sed -i.bck "s~_SOLR_URL_~${solr_url}~g" $conffolder/appsettings.json

# SYNAPSE
sed -i.bck "s~_SYNAPSE_URL_~${synapse_url}~g" $conffolder/appsettings.json
sed -i.bck "s~_SYNAPSE_USER_~${synapse_user}~g" $conffolder/appsettings.json
sed -i.bck "s~_SYNAPSE_PW_~${synapse_pass}~g" $conffolder/appsettings.json

if kubectl -n docintel get cm | grep -q docintel-config ; then
    echo ""
    echo "=== REPLACE DOCINTEL CONFIG"
    kubectl -n docintel create configmap docintel-config \
       --from-file=./app-config/appsettings.json \
       --from-file=./app-config/nlog.config \
       --dry-run=client -o yaml | kubectl replace -f -
else
    echo ""
    echo "=== CREATE DOCINTEL CONFIG"
    kubectl -n docintel create configmap docintel-config \
       --from-file=./app-config/appsettings.json \
       --from-file=./app-config/nlog.config
fi

kubectl -n docintel label configmaps docintel-config --overwrite \
    app.kubernetes.io/component=config \
    app.kubernetes.io/instance=app-config \
    app.kubernetes.io/name=app-config \
    app.kubernetes.io/part-of=docintel

kubectl -n docintel get configmaps docintel-config -o yaml > deploy/config-map.yaml

echo ""
echo "=== DONE"
