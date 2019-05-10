#!/usr/bin/env bash
#
# This scrip will configure searchguard
#

# file permissions
chmod -R 0770 $SG_CERT_DIR
chown 1000:0 $SG_CERT_DIR

# set JAVA_HOME and java to PATH
export JAVA_HOME=/usr/share/elasticsearch/jdk
export PATH=${PATH}:${JAVA_HOME}/bin

/usr/local/bin/wait_until_started.sh

/usr/local/bin/sgusers.sh
/usr/local/bin/sgadmin.sh