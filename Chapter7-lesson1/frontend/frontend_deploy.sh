#!/bin/bash
set +e

docker network create -d bridge sausage_network || true
docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}
docker pull $CI_REGISTRY_IMAGE/sausage-frontend:latest
docker stop frontend || true
docker rm frontend || true

set -e
docker run -d --name frontend \
    --network=sausage_network \
    --restart always \
    --pull always \
    -p 8080:80 \
    $CI_REGISTRY_IMAGE/sausage-frontend:latest
