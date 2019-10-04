#!/usr/bin/env bash

general_status=0

echo "calling elasticsearch _prometheus/metrics endpoint"
metrics=$(curl -X GET --silent -k -u "kibana:kibana" "https://localhost:9200/_prometheus/metrics")

echo -n "TEST if elasticsearch prometheus metrics contain es_os_mem_used_percent..."
if [[ "$metrics" =~ es_os_mem_used_percent\{cluster=\"my-cluster ]]; then
  echo "OK"
else
  echo "failed!"
  ((general_status++))
fi

echo -n "TEST if elasticsearch prometheus metrics contain es_cluster_shards_active_percent..."
if [[ "$metrics" =~ es_cluster_shards_active_percent\{cluster=\"my-cluster ]]; then
  echo "OK"
else
  echo "failed!"
  ((general_status++))
fi

exit ${general_status}