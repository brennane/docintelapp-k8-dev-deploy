profile=${1:?usage $0 \{lab | rancher-desktop | docker-desktop \}}
# BITNAMI is owned by VMWare and provides well-respected helm charts

##
## prepare HELM offerings (postgres, solr, and rabbitmq)
## prepare vertex/synapse-cortex module
##
## after these are installed postgres and solr need customization 
## handled next, in the install-common script.
##

repo=$(cat ,REPO)

if ! echo "${profile}" | grep -qE '^lab|rancher-desktop|docker-desktop$'; then
   echo "I need a profile in [lab | rancher-desktop | docker-desktop ]";
   exit
fi

echo "=== CREATE NAMESPACE YAML ..."
kubectl create ns docintel --dry-run=client -o yaml > common/namespace.yaml
REPOSITORY="${repo}" envsubst < static/synapse.yaml.template  > common/synapse.yaml

case ${profile} in
    lab)
        # just a little bigger
        solr_zookeeper="true"
        solr_options="--set auth.enabled=false"
        solr_options="${solr_options} --set replicaCount=2"
        solr_options="${solr_options} --set collectionReplicas=2"
        di_accessmode=ReadWriteMany
        ;;
    docker-desktop | rancher-desktop)
        profile="rancher-desktop"
        solr_zookeeper="true"
        solr_options="--set auth.enabled=false"
        solr_options="${solr_options} --set replicaCount=1"
        solr_options="${solr_options} --set collectionReplicas=1"
        # only have pod/solr-0 
        di_accessmode=ReadWriteOnce
        ;;
    *) 
       echo "How does this even happen??"
       exit
    ;;
esac


echo "${profile}" > ,PROFILE
echo "${solr_zookeeper}" > ,SOLR
echo "${di_accessmode}" > ,PVC_MODE

echo ""
echo "=== HEML TEMPLATE RABBITMQ ..."
echo "=== see https://artifacthub.io/packages/helm/bitnami/rabbitmq"
helm template -n docintel rabbitmq  bitnami/rabbitmq --version 11.2.0 > common/rabbitmq.yaml
echo ""
echo "=== HEML TEMPLATE POSTGRESQL ..."
echo "=== see https://artifacthub.io/packages/helm/bitnami/postgresql"
helm template -n docintel postgresql bitnami/postgresql --version 12.1.3 > common/postgresql.yaml
echo ""
echo "=== HEML TEMPLATE SOLR ..."
echo "=== see https://artifacthub.io/packages/helm/bitnami/solr"
helm template -n docintel solr bitnami/solr --version 7.0.1 ${solr_options} > common/solr.yaml

if ! [ "${repo}" = "docker.io" ] ; then
    # in truth we can pass these to helm , why do it this way (because I
    # already did)
    echo ""
    echo "=== REQUESTING HARBOR IMAGE CACHE ..."
    sed -i.bck "s~docker.io/~${repo}/~"g common/solr.yaml
    sed -i.bck "s~docker.io/~${repo}/~"g common/synapse.yaml
    sed -i.bck "s~docker.io/~${repo}/~"g common/rabbitmq.yaml
    sed -i.bck "s~docker.io/~${repo}/~"g common/postgresql.yaml
fi

echo ""
echo "=== READY"
