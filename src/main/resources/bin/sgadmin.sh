#!/usr/bin/env bash

echo "configure searchguard via sgadmin.sh ..."

chmod +x /usr/share/elasticsearch/plugins/search-guard-6/tools/sgadmin.sh

/usr/share/elasticsearch/plugins/search-guard-6/tools/sgadmin.sh \
-cacert ${SG_CERT_DIR}/${ROOT_CA} \
-cert ${SG_CERT_DIR}/${ADMIN_PEM} \
-key ${SG_CERT_DIR}/${ADMIN_KEY} \
-cd ${SG_CONFIG_DIR} \
-icl \
-keypass ${ADMIN_KEY_PASS} \
-h $HOSTNAME \
-nhnv