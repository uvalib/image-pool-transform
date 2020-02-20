orig_mods_dir=$1
intermediate_mods_dir=$2
solr_dir=$3
solr_add_doc=$4
solr_post_url=$5

if [[ "${orig_mods_dir}" != "" ]] ; then
    echo "normalize all mods files in dir ${orig_mods_dir}"
    java -jar saxon9.jar -s:${orig_mods_dir} -xsl:./normalizeMODS.xsl -o:${intermediate_mods_dir} 
else
    echo "skipping normalize step"
fi

if [[ "${intermediate_mods_dir}" != "" ]] ; then
    echo "process intermediate files in dir ${intermediate_mods_dir} to solr add documents in dir ${solr_dir}" 
    java -jar saxon9.jar -s:${intermediate_mods_dir} -xsl:./mods2solr.xsl -o:${solr_dir}
    echo "rename output files in dir ${solr_dir} from   xxx:xxxxx-mods.xml  to xxx:xxxx-solr.xml"
    find ${solr_dir} -type f -name "*mods*" | sed -n "s/\(.*\)mods\.xml$/& \1solr.xml/p" | xargs -n 2 mv
else
    echo "skipping generate (and rename) solr docs steps "
fi

if [[ "${solr_add_doc}" != "" ]] ; then
    echo "concatenate solr docs into large add doc command file named ${solr_add_doc}"
    cat ./add.xml > ${solr_add_doc}
    cat ${solr_dir}/*.xml >> ${solr_add_doc}
    cat ./xadd.xml >> ${solr_add_doc}
else
    echo "skipping concatenate step"
fi

if [[ "${solr_post_url}" != "" ]] ; then
    echo "posting concatenated solr docs to URL ${solr_post_url}"
    java -Durl=${solr_post_url} -jar post.jar ${solr_add_doc}
else
    echo "skipping direct post to solr"
fi
    

