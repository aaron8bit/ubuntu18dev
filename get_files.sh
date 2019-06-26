#!/bin/bash

PWD=$(pwd)
DESTINATION=${1:-.}
cd ${DESTINATION}

if [[ ! -f vault_1.1.3_linux_amd64.zip ]]; then
  echo "Getting vault 1.1.3"
  curl -fsSLO https://releases.hashicorp.com/vault/1.1.3/vault_1.1.3_linux_amd64.zip
  curl -fsSLO https://releases.hashicorp.com/vault/1.1.3/vault_1.1.3_SHA256SUMS
fi
grep linux_amd64 vault_1.1.3_SHA256SUMS | shasum --algorithm 256 --check -
if [[ $? -ne 0 ]]; then
  echo "ERROR: checksum failed"
  cd ${PWD}
  exit 1
fi

if [[ ! -f terraform_0.12.3_linux_amd64.zip ]]; then
  echo "Getting terraform 0.12.3"
  curl -fsSLO https://releases.hashicorp.com/terraform/0.12.3/terraform_0.12.3_linux_amd64.zip
  curl -fsSLO https://releases.hashicorp.com/terraform/0.12.3/terraform_0.12.3_SHA256SUMS
fi
grep linux_amd64 terraform_0.12.3_SHA256SUMS | shasum --algorithm 256 --check -
if [[ $? -ne 0 ]]; then
  echo "ERROR: checksum failed"
  cd ${PWD}
  exit 1
fi

if [[ ! -f kops-linux-amd64 ]]; then
  echo "Getting kops 1.12.2"
  curl -fsSLO https://github.com/kubernetes/kops/releases/download/1.12.2/kops-linux-amd64
  curl -fsSLO https://github.com/kubernetes/kops/releases/download/1.12.2/kops-linux-amd64-sha1
fi
export KOPS_SHA1=$(cat kops-linux-amd64-sha1)
echo "${KOPS_SHA1}  kops-linux-amd64" | shasum --algorithm 1 --check -
if [[ $? -ne 0 ]]; then
  echo "ERROR: checksum failed"
  cd ${PWD}
  exit 1
fi

cd ${PWD}
