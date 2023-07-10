#!/usr/bin/env bash

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# global env var can control install dir.
INSTALL_DIR=${PROVISIONING_LIB:-/tmp}
CWD=$(pwd)
LOG_PREFIX="+ [BUILD]::[DOCKER]"

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value

# Build Info
BUILD_LANG=python
BUILD_VERSION=3.7.4
BUILD_VARIANT=xenial
BUILD_NAME=${BUILD_LANG}${BUILD_VERSION}+${BUILD_VARIANT/\//-}
LANG_SHA256=""
LOG_PREFIX+="::[${BUILD_NAME}]"

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "${LOG_PREFIX}::[INSTALL_DIR]::[${INSTALL_DIR}]"
echo "${LOG_PREFIX}::[CWD]::[${CWD}]"
echo "${LOG_PREFIX}::[BUILD_LANG]::[${BUILD_LANG}]"
echo "${LOG_PREFIX}::[BUILD_VERSION]::[${BUILD_VERSION}]"
echo "${LOG_PREFIX}::[BUILD_VARIANT]::[${BUILD_VARIANT}]"
echo "${LOG_PREFIX}::[LANG_SHA256]::[${LANG_SHA256}]"
echo "${LOG_PREFIX}::[BUILD_NAME]::[${BUILD_NAME}]"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

$(cat /whoami >> /whohaveibeen) || true
$(echo "${BUILD_NAME}" > /whoami) || true

source ${INSTALL_DIR}/common/container/build.init.sh
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
# User level provisioning.
##########################

WORKING_DIR=/go
source ${INSTALL_DIR}/16/python.sh "${BUILD_VERSION}"

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
source ${INSTALL_DIR}/common/container/build.exit.sh