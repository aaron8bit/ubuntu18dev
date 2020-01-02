#!/bin/bash

PWD=$(pwd)
DESTINATION=${1:-.}
cd ${DESTINATION}

#if [[ ! -f apache-maven-3.3.9-bin.tar.gz ]]; then
#  echo "Getting maven 3.3.9"
#  curl -fsSLO http://www-eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
#  curl -fsSLO http://www-eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz.sha1
#fi
#export MVN_SHA1=$(cat apache-maven-3.3.9-bin.tar.gz.sha1)
#echo "${MVN_SHA1}  apache-maven-3.3.9-bin.tar.gz" | shasum --algorithm 1 --check -
#if [[ $? -ne 0 ]]; then
#  echo "ERROR: checksum failed"
#  cd ${PWD}
#  exit 1
#fi

#if [[ ! -f gradle-3.5-all.zip ]]; then
#  echo "Getting gradle 3.5"
#  curl -fsSLO https://services.gradle.org/distributions/gradle-3.5-all.zip
#fi
#echo "6c10209bd7ba0a2dd1191ad97e657c929d38f676  gradle-3.5-all.zip" | shasum --algorithm 1 --check -
#if [[ $? -ne 0 ]]; then
#  echo "ERROR: checksum failed"
#  cd ${PWD}
#  exit 1
#fi

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

if [[ ! -f install_ohmyzsh.sh ]]; then
  echo "Getting install file for oh-my-zsh"
  curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -o install_ohmyzsh.sh
fi
echo "f423ddfb1d0b6a849b229be5b07a032c10e13c6f  install_ohmyzsh.sh" | shasum --algorithm 1 --check -
if [[ $? -ne 0 ]]; then
  echo "ERROR: checksum failed"
  cd ${PWD}
  exit 1
fi

cd ${PWD}
