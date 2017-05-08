#!/bin/bash

THIS_SCRIPT=${BASH_SOURCE[0]}
THIS_DIRECTORY=$(cd $(dirname ${THIS_SCRIPT}) && pwd)

REPOSITORY="aaron8bit"
IMAGE_NAME="centos7dev"
IMAGE="${REPOSITORY}/${IMAGE_NAME}"

VERSION=$(cat ${THIS_DIRECTORY}/.version)
DATE_STAMP=$(date +%Y%m%d-%H%M)
IMAGE_TAG="${VERSION}-${DATE_STAMP}"

docker build -t ${IMAGE}:${IMAGE_TAG} ${THIS_DIRECTORY}

if [[ $? -eq 0 ]]; then
  docker tag ${IMAGE}:${IMAGE_TAG} ${IMAGE}:latest
fi
