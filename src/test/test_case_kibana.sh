#!/usr/bin/env bash

general_status=0

echo -n "TEST if kibana status endpoint is returning HTTP 200..."
RET=1
count=0
while ((RET != 0 && count < 90)); do
  sleep 1
  curl -X GET --silent -f "http://localhost:5601/status" >/dev/null 2>&1
  RET=$?
  echo -n "."
  ((count++))
done
if ((RET != 0)); then
  echo "failed!"
  ((general_status++))
else
  echo "OK"
fi

echo -n "TEST if kibana overall state is green..."
overall_status="dummy"
itterations=0
while [[ "${overall_status,,}" != "green" && $itterations -lt 20 ]]; do
  sleep 1
  overall_status=$(curl -X GET --silent -k -f -u "kibana:kibana" "http://localhost:5601/api/status" | jq -r .status.overall.state)
  echo -n "."
  ((itterations++))
done
if [ "${overall_status,,}" != "green" ]; then
  echo "failed: overall state is \"${overall_status}\""
  ((general_status++))
else
  echo "OK"
fi

exit ${general_status}
