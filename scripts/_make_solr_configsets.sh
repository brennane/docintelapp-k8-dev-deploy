langs=`ls /bitnami/solr/server/solr/configsets/_default/conf/lang/stopwords_??.txt -1 | cut -c 67-68`

for what in tag document source facet ; do
    src="/tmp/solr_configsets/${what}"

    echo ""
    echo "--- UPLOADING ${what} TO ZOOKEEPER ---"
    solr zk  -z solr-zookeeper.docintel.svc.cluster.local/solr upconfig -n ${what} -d "${src}"

    echo ""
    echo "--- CREATING COLLECTION ${what} ---"
    # curl "http://localhost:8983/solr/admin/collections?action=DELETE&name=${what}"
    curl "http://localhost:8983/solr/admin/collections?action=CREATE&name=${what}&collection.configName=${what}&numShards=1&wt=xml"
done

echo "=== CLEANING UP ===="
