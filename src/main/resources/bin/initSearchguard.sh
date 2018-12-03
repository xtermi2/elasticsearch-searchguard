#!/usr/bin/env bash
#
# This scrip will configure searchguard
#

# file permissions
chmod -R 0770 $SG_CERT_DIR
chown 1000:0 $SG_CERT_DIR

/usr/local/bin/wait_until_started.sh

/usr/local/bin/sgusers.sh
/usr/local/bin/sgadmin.sh