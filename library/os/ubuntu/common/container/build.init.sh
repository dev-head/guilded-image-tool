#!/usr/bin/env bash

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# global env var can control install dir.
INSTALL_DIR=${PROVISIONING_LIB:-/tmp}

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

source ${INSTALL_DIR}/common/container/pkg_mgr.init.sh
source ${INSTALL_DIR}/common/container/tools.sh
source ${INSTALL_DIR}/common/container/rsync-docker-root.sh