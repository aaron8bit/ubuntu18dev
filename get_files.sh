#!/bin/bash

PWD=$(pwd)
DESTINATION=${1:-.}
cd ${DESTINATION}

function get_files {
  name=$1
  version=$2
  file_url=$3
  file_src=$4
  file_dst=$5
  file_sha=$6
  if [[ ! -f ${file_dst} ]]; then
    echo "Getting ${name} version ${version}"
    echo "  curl -fsSL ${file_url}/${file_src} -o ${file_dst}"
    curl -fsSL ${file_url}/${file_src} -o ${file_dst}
    echo "  curl -fsSLO ${file_url}/${file_sha}"
    curl -fsSLO ${file_url}/${file_sha}
  fi
}

function exit_on_failed_checksum {
  file=$1
  status=$2
  if [[ ${status} -ne 0 ]]; then
    echo "ERROR: ${file}: failed to verify file"
    exit 1
  fi
}

function check_version_format {
  TEST_VERSION="12.34.56"
  for version in TEST_VERSION $@
  do
    if [[ ! $(eval echo \$${version}) =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo "ERROR: invalid version: ${version}=$(eval echo \$${version})"
      exit 1
    fi
  done
}

function export_vars {
  for var in TERRAFORM_VER TERRAFORM_DST VAULT_VER VAULT_DST KOPS_VER KOPS_DST AWS_VER AWS_DST
  do
    echo "export ${var}=$(eval echo \$${var})"
  done
}

TERRAFORM_VER=$(wget -O - https://releases.hashicorp.com/terraform/ 2>/dev/null | grep terraform_ | head -1 | sed 's/.*>terraform_//' | sed 's/<.*//')
TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VER}"
TERRAFORM_SRC="terraform_${TERRAFORM_VER}_linux_amd64.zip"
TERRAFORM_DST="${TERRAFORM_SRC}"
TERRAFORM_SHA="terraform_${TERRAFORM_VER}_SHA256SUMS"

VAULT_VER=$(wget -O - https://releases.hashicorp.com/vault/ 2>/dev/null | grep vault_ | grep -v '+ent' | head -1 | sed 's/.*>vault_//' | sed 's/<.*//')
VAULT_URL="https://releases.hashicorp.com/vault/${VAULT_VER}"
VAULT_SRC="vault_${VAULT_VER}_linux_amd64.zip"
VAULT_DST="${VAULT_SRC}"
VAULT_SHA="vault_${VAULT_VER}_SHA256SUMS"

KOPS_VER=$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)
KOPS_URL="https://github.com/kubernetes/kops/releases/download/${KOPS_VER}"
KOPS_SRC="kops-linux-amd64"
KOPS_DST="${KOPS_SRC}.${KOPS_VER}"
KOPS_SHA="kops-linux-amd64-sha1"

AWS_VER="LATEST"
AWS_URL="https://d1vvhvl2y92vvt.cloudfront.net"
AWS_SRC="awscli-exe-linux-x86_64.zip"
AWS_DST="${AWS_SRC}"
AWS_GPG="awscli-exe-linux-x86_64.zip.sig"

#
# CHECK LATEST VERSIONS
#
check_version_format TERRAFORM_VER VAULT_VER KOPS_VER

#
# GET VAULT_VER
#
get_files vault $VAULT_VER $VAULT_URL $VAULT_SRC $VAULT_DST $VAULT_SHA
echo "Checking file ${VAULT_DST}"
grep linux_amd64 ${VAULT_SHA} | shasum --algorithm 256 --check -
exit_on_failed_checksum vault $?

#
# TERRAFORM_VER
#
get_files terraform $TERRAFORM_VER $TERRAFORM_URL $TERRAFORM_SRC $TERRAFORM_DST $TERRAFORM_SHA
echo "Checking file ${TERRAFORM_DST}"
grep linux_amd64 ${TERRAFORM_SHA} | shasum --algorithm 256 --check -
exit_on_failed_checksum terraform $?

#
# KOPS_VER
#
get_files kops $KOPS_VER $KOPS_URL $KOPS_SRC $KOPS_DST $KOPS_SHA
echo "Checking file ${KOPS_DST}"
export KOPS_SHA1=$(cat ${KOPS_SHA})
echo "${KOPS_SHA1}  ${KOPS_DST}" | shasum --algorithm 1 --check -
exit_on_failed_checksum kops $?

#
# GET LATEST AWS CLI
#
get_files awscli $AWS_VER $AWS_URL $AWS_SRC $AWS_DST $AWS_GPG
gpg --import "${AWS_GPG}.pub"
exit_on_failed_checksum awscli $?
gpg --verify ${AWS_GPG} ${AWS_DST}
exit_on_failed_checksum awscli $?

cd ${PWD}
echo "SUCCESS: all files present and verified"
echo
export_vars

