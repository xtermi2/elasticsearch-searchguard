#!/usr/bin/env bash

RET=1
count=0
while ((RET != 0 && count < 30)); do
  sleep 5
  echo "Waiting for Elasticsearch..."
  curl -XGET -k -u "elastic:elastic" "https://localhost:9200/" >/dev/null 2>&1
  RET=$?
  echo "Elasticsearch status=${RET}"
  ((count++))
done
