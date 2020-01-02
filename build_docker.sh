#!/bin/bash

THIS_SCRIPT=${BASH_SOURCE[0]}
THIS_DIRECTORY=$(cd $(dirname ${THIS_SCRIPT}) && pwd)

REPOSITORY="aaron8bit"
IMAGE_NAME="ubuntu18dev"
IMAGE="${REPOSITORY}/${IMAGE_NAME}"

VERSION=$(cat ${THIS_DIRECTORY}/.version)
DATE_STAMP=$(date +%Y%m%d-%H%M)
IMAGE_TAG="${VERSION}-${DATE_STAMP}"

${THIS_DIRECTORY}/get_files.sh ${THIS_DIRECTORY} ||
  { echo "ERROR: get_files.sh failed, exiting" ; exit 1 ; }

if [[ -e "build_docker.env" ]]; then
  for arg in $(cat build_docker.env)
  do
    BUILDARGS="${BUILDARGS} --build-arg ${arg}"
  done
  echo "docker build -t ${IMAGE}:${IMAGE_TAG} ${THIS_DIRECTORY} ${BUILDARGS}"
  docker build -t ${IMAGE}:${IMAGE_TAG} ${THIS_DIRECTORY} ${BUILDARGS}
else
  echo "ERROR: build_docker.env not found, exiting"
  exit 1
fi

if [[ $? -eq 0 ]]; then
  echo "Created new image: ${IMAGE}:${IMAGE_TAG}"
  docker tag ${IMAGE}:${IMAGE_TAG} ${IMAGE}:${VERSION}
  echo "Tagged image as:   ${IMAGE}:${VERSION}"
  docker tag ${IMAGE}:${IMAGE_TAG} ${IMAGE}:latest
  echo "Tagged image as:   ${IMAGE}:latest"
fi
