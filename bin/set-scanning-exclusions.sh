#!/bin/sh

source $(dirname $0)/internal/common.sh
checkIntegrationTestsResourcesExists

# Wait for ZAP Proxy to be available
ZAP_CONTAINER_ID="$(docker-compose ps -q zap-proxy)"
RETRIES=0

until docker ps --filter "id=${ZAP_CONTAINER_ID}" --format '{{ .Status }}' | grep --quiet '(healthy)'
do
  echo "ZAP Proxy not healthy yet"
  sleep 10
  if [ ${RETRIES} -gt 36 ]
  then
    echo "ZAP Proxy container not healthy after reaching maximum retries, exiting"
    exit 1
  else
    RETRIES=$(($RETRIES+1))
  fi
done

# Exclude external domains from scanning
echo "Setting scanning exclusions"

docker-compose exec $@ zap-proxy zap-cli exclude '.*www.payments.service.gov.uk.*'
docker-compose exec $@ zap-proxy zap-cli exclude '.*www.google-analytics.com.*'
docker-compose exec $@ zap-proxy zap-cli exclude '.*edgedl/chrome.*'
docker-compose exec $@ zap-proxy zap-cli exclude '.*authentication-web.*'
docker-compose exec $@ zap-proxy zap-cli exclude '.*(js|img|stylesheets)/lib.*'
