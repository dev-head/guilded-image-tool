#!/usr/bin/env bash

export export WORKING_DIR="${WORKING_DIR:-/var/www}" && \
    export NGINX_USER="${1:-www-data}"  && \
    export NGINX_GROUP="${2:-www-data}" && \
    export DEBIAN_FRONTEND=noninteractive && \
    export DPKG_ARCH=$(dpkg --print-architecture)

echo "[WORKING_DIR]::[${WORKING_DIR}]"  && \
    echo "[NGINX_USER]::[${NGINX_USER}]"  && \
    echo "[NGINX_GROUP]::[${NGINX_GROUP}]"  && \
    echo "[DPKG_ARCH]::[${DPKG_ARCH}]"


echo "[INSTALLING]::[nginx]"
apt-get update

#
# Install [WEBSERVER]
# -------------------------------------------------------------------------------------------------------------------- #
apt-get --yes --force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install \
    nginx nginx-extras

# ==================================================================================================================== #

#
# Configure [WEBSERVER]
# -------------------------------------------------------------------------------------------------------------------- #
echo "[creating]::[${NGINX_USER}:${NGINX_GROUP} user|group|perms]"
source ${INSTALL_DIR}/common/container/create-user.sh "${NGINX_USER}:1000" "${NGINX_GROUP}:1000"

mkdir -p /var/log/nginx
chown root:${NGINX_GROUP} /var/log/nginx
chmod o-rwx /var/log/nginx

rm -Rf "${WORKING_DIR}" /var/www/html
mkdir -p  "${WORKING_DIR}"
chown -R ${NGINX_USER}:${NGINX_GROUP} "${WORKING_DIR}"
