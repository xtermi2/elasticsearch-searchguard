#!/usr/bin/env bash
# this is the docker entrypoint.

echo "run searchguard init in background. Script waits until elasticsearch is up and running and then configures searchguard"
/usr/local/bin/initSearchguard.sh &

echo "start elasticsearch"
/usr/local/bin/docker-entrypoint.sh "$@"

