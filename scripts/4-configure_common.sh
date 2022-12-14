profile=$(cat ,PROFILE)
solr_zookeeper=$(cat ,SOLR)
branch=$(cat static/DOCINTEL_BRANCH)

echo ""
echo "=== CONFIGURING POSTGRES"
sh scripts/_configure_postgres.sh

echo ""
echo "=== CONFIGURING SOLR (docintel ${branch} solrCloud ${solr_zookeeper})"
kubectl -n docintel cp scripts/_make_solr_configsets_remote.sh  --container solr solr-0:/tmp/make_solr_configsets.sh
kubectl exec -i -n docintel --container solr solr-0 -- sh /tmp/make_solr_configsets.sh $branch $solr_zookeeper create

echo ""
echo "=== DONE"
