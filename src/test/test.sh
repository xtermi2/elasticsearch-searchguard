#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd $DIR

ls -l
ls -l test-certs

echo "stating docker-compose"
docker-compose up -d

docker-compose ps
docker-compose logs elasticsearch_searchguard_1
docker exec -i -t elasticsearch_searchguard_1 /bin/ls -l /usr/share/elasticsearch/config
docker exec -i -t elasticsearch_searchguard_1 /bin/ls -l /usr/share/elasticsearch/config/certificates

./wait_until_started.sh
docker-compose ps
docker-compose logs elasticsearch_searchguard_1

general_status=0
echo "executing testcases"

./test_case_kibana.sh
((general_status = general_status + $?))
./test_case_cluster_health.sh
((general_status = general_status + $?))
./test_case_prometheus_endpoint.sh
((general_status = general_status + $?))
./test_case_filebeats.sh
((general_status = general_status + $?))

echo "#########################################"
if ((general_status > 0)); then
  echo "${general_status} tests FAILED, see logs above!"
else
  echo "SUCCESS - all tests passed!"
fi
echo "#########################################"

docker-compose ps
docker-compose down

exit ${general_status}
