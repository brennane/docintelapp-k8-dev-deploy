profile=$(cat ,PROFILE)
solr_zookeeper=$(cat ,SOLR)
branch=$(cat static/DOCINTEL_BRANCH)

echo ""
echo "=== CONFIGURING POSTGRES"
sh scripts/_configure_postgres.sh

echo ""
echo "=== CONFIGURING SOLR (docintel ${branch} solrCloud ${solr_zookeeper})"
sh scripts/_make_solr_configsets_prep.sh ${branch}
tar cf - solr_configsets | kubectl exec -i -n docintel --container solr solr-0 -- tar xf - -C /tmp
kubectl -n docintel cp scripts/_make_solr_configsets.sh  --container solr solr-0:/tmp/make_solr_configsets.sh
kubectl exec -i -n docintel --container solr solr-0 -- sh /tmp/make_solr_configsets.sh

echo ""
echo "=== DONE"
