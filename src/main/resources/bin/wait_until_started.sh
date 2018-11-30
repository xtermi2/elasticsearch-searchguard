#!/usr/bin/env bash

RET=1
while [[ RET -ne 0 ]]; do
    sleep 5
    echo "Stalling for Elasticsearch..."
    curl -XGET -k -u "elastic:$$ELASTIC_PWD" "https://localhost:9200/" >/dev/null 2>&1
    RET=$?
    echo "Elasticsearch status=${RET}"
done
