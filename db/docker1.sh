#!/bin/bash
echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
docker pull mahadikbs/k8s-prom-grafana:latest
docker run -d -p 8080:8080 -p 9090:9090 -p 16443:16443 -p 3000:3000 --name k8s-server mahadikbs/k8s-prom-grafana:latest