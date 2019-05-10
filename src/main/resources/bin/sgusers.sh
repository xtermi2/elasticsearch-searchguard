#!/usr/bin/env bash

echo "set passwords for pre defined users from environment variables in searchguard config files"

chmod +x /usr/share/elasticsearch/plugins/search-guard-7/tools/hash.sh

hash=$(/usr/share/elasticsearch/plugins/search-guard-7/tools/hash.sh -p $ELASTIC_PWD)
sed -ri "s|hash:[^\r\n#]*#elastic|hash: \'$hash\' #elastic|" ${SG_CONFIG_DIR}/sg_internal_users.yml

hash=$(/usr/share/elasticsearch/plugins/search-guard-7/tools/hash.sh -p $KIBANA_PWD)
sed -ri "s|hash:[^\r\n#]*#kibana|hash: '$hash' #kibana|" ${SG_CONFIG_DIR}/sg_internal_users.yml

hash=$(/usr/share/elasticsearch/plugins/search-guard-7/tools/hash.sh -p $BEATS_PWD)
sed -ri "s|hash:[^\r\n#]*#beats|hash: '$hash' #beats|" ${SG_CONFIG_DIR}/sg_internal_users.yml

cat ${SG_CONFIG_DIR}/sg_internal_users.yml