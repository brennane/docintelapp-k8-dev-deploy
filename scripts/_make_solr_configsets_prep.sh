docintel_version=${1?$0 missing docintel version e.g. v2.1.2}
config_uri="https://raw.githubusercontent.com/docintelapp/DocIntel/${docintel_version}/conf"

langs="ar bg ca cz da de el en es et eu fa fi fr ga gl hi hu hy id it ja lv nl no pt ro ru sv th tr"

base_dir="./solr_configsets"

rm -rf "${base_dir}"

echo ""
echo "=== FETCHING MANAGED SCHEMAS ( $docintel_version )"
for what in tag document source facet ; do
    dest="${base_dir}/${what}/conf/"
    mkdir -p "${dest}/lang"

    curl "${config_uri}/managed-schema-${what}" -o ${dest}/managed-schema.xml
    cp static/solrconfig-91-default.xml ${dest}/solrconfig.xml

    # 
    #  Solr cares about these, I dont ... empty files!
    #  (alt, copy from solr _default when uploading collections)
    # 
    for stub  in stopwords.txt synonyms.txt protwords.txt ; do 
        echo '' > "${dest}/${stub}"
    done
    for lang in $langs ; do
        # cp /bitnami/solr/server/solr/configsets/_default/conf/lang/stopwords_${lang}.txt "${dest}/conf/lang/stopwords_${lang}.txt"
        echo '' > "${dest}/lang/stopwords_${lang}.txt"
    done
done

cp static/solrconfig-91-extracting.xml "${base_dir}/document/config/solrconfig.xml"

echo ""
echo "=== DONE"
