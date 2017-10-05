#!/bin/sh

if [[ ! -e 'integration-tests' ]]
then
  echo "Integration tests not available, have you linked the directory? Check the README file for further details.\n"
  exit 123
fi

OPTIONS="-f integration-tests/docker-compose.yml -f docker-compose.yml -f docker-compose-citizen.yml --project-directory ."

docker-compose ${OPTIONS} up --no-deps integration-tests

if [ $? != 0 ]; then
  echo 'Integration tests failed'
  exit 1
fi

mkdir -p reports
docker-compose ${OPTIONS} exec zap-proxy zap-cli report -o /zap/reports/zap-scan-report.html -f html