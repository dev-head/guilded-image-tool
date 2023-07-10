#!/usr/bin/env bash

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# global env var can control install dir.
INSTALL_DIR=${PROVISIONING_LIB:-/tmp}

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value

$(cat /whoami >> /whohaveibeen) || true
$(echo "base_app" > /whoami) || true

source ${INSTALL_DIR}/common/container/build.init.sh
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
# User level provisioning.
##########################

export DEBIAN_FRONTEND=noninteractive
apt-get --yes --force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install supervisor

source ${INSTALL_DIR}/common/container/create-user.sh "application:1000" "application:1000"

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
source ${INSTALL_DIR}/common/container/build.exit.sh
