for f in modsxml/*.xml
do
  name=$(basename $f)
  pid=${name/-mods.xml/}
  echo "$f ($pid)"
  # Normalize mods
  saxon -s:$f -xsl:./normalizeMODS.xsl -o:./$pid-mods-normal.xml
  # Create solr
  saxon -s:./$pid-mods-normal.xml -xsl:./mods2solr.xsl -o:./solr/$pid-solr.xml id=$pid
done
