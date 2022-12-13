docintel_version=${1?$0 missing docintel version e.g. v2.1.2}
zookeeper=${2?$0 missing zookeepr-flag (true | false)}
config_uri="https://raw.githubusercontent.com/docintelapp/DocIntel/${docintel_version}/conf"

langs=`ls /bitnami/solr/server/solr/configsets/_default/conf/lang/stopwords_??.txt -1 | cut -c 67-68`

for what in tag document source facet ; do
    if [ "X${zookeeper}" = "Xtrue" ] ; then 
        dest="/tmp/solr_configsets/${what}"
        rm -rf "${dest}"

        echo ""
        echo "=== LOADING PROTOTYPE config (for stopwords etc) ==="
        ## solr zk  -z solr-zookeeper.docintel.svc.cluster.local/solr downconfig -n _default -d "${dest}"
        mkdir -p "${dest}/conf"
        mkdir -p "${dest}/conf/lang"

        for stub  in stopwords.txt synonyms.txt protwords.txt ; do 
            echo '' > "${dest}/conf/${stub}"
        done
        for lang in $langs ; do
            # cp /bitnami/solr/server/solr/configsets/_default/conf/lang/stopwords_${lang}.txt "${dest}/conf/lang/stopwords_${lang}.txt"
            echo '' > "${dest}/conf/lang/stopwords_${lang}.txt"
        done

        echo ""
        echo "=== FETCHING ${what} from ${config_uri} ==="
        curl "${config_uri}/solrconfig-${what}.xml" -o ${dest}/conf/solrconfig.xml
        ## patch the extraction library
        sed -i.bck '/<lib /  s,/..}/contrib,}/modules,' ${dest}/conf/solrconfig.xml
        sed -i.bck '/solr-cell-/d' ${dest}/conf/solrconfig.xml
        rm ${dest}/conf/solrconfig.xml.bck
        ## end patch
        curl "${config_uri}/managed-schema-${what}" -o ${dest}/conf/managed-schema.xml

        echo ""
        echo "--- UPLOADING ${what} TO ZOOKEEPER ---"
        solr zk  -z solr-zookeeper.docintel.svc.cluster.local/solr upconfig -n ${what} -d "${dest}"
        # solr zk  -z solr-zookeeper.docintel.svc.cluster.local cp -r "${dest}" zk:/configs/${what}

        echo ""
        echo "--- CREATING COLLECTION ${what} ---"
        # curl "http://localhost:8983/solr/admin/collections?action=CREATE&name=${what}&collection.configName=${what}&numShards=1&replicationFactor=1&wt=xml"
        curl "http://localhost:8983/solr/admin/collections?action=CREATE&name=${what}&collection.configName=${what}&numShards=1&wt=xml"
    else
        # stand-alone (no solrCloud)
        dest=/tmp/${what}
        rm -rf "${dest}"

        cp -pr /bitnami/solr/server/solr/configsets/_default ${dest}
        echo "=== FETCHING ${what} from ${config_uri} ==="
        curl "${config_uri}/solrconfig-${what}.xml" -o ${dest}/conf/solrconfig.xml
        sed -i.bck '/<lib /  s,/..}/contrib,}/modules,' ${dest}/conf/solrconfig.xml
        rm ${dest}/conf/solrconfig.xml.bck
        curl "${config_uri}/managed-schema-${what}" -o ${dest}/conf/managed-schema.xml

        echo ""
        echo "=== CREATING CORE ${what}"
        solr create_core -c ${what} -d ${dest}
    fi
done

echo "=== CLEANING UP ===="
