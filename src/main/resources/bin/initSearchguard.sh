#!/usr/bin/env bash
#
# This scrip will configure searchguard
#

/usr/local/bin/wait_until_started.sh

/usr/local/bin/sgusers.sh
/usr/local/bin/sgadmin.sh