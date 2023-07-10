#!/usr/bin/env bash

export BUILD_LANG="php" && \
    export BUILD_LANG_VERSION="7.2"  && \
    export VERSION_STRING="${BUILD_LANG}${BUILD_LANG_VERSION}"  && \
    export NGINX_USER="${2:-www-data}"  && \
    export NGINX_GROUP="${3:-www-data}" && \
    export DEBIAN_FRONTEND=noninteractive

echo "[BUILD_LANG]::[${BUILD_LANG}]"     && \
    echo "[BUILD_LANG_VERSION]::[${BUILD_LANG_VERSION}]"  && \
    echo "[VERSION_STRING]::[${VERSION_STRING}]"  && \
    echo "[NGINX_USER]::[${NGINX_USER}]"  && \
    echo "[NGINX_GROUP]::[${NGINX_GROUP}]"

LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php

# Install stuff
echo "Installing [${VERSION_STRING}] and nginx"
apt-get update

# Install Webserver
apt-get --yes --force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install \
    nginx nginx-extras

# Install Language.
apt-get --yes --force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install \
    "${VERSION_STRING}" \
    "${VERSION_STRING}-bcmath" \
    "${VERSION_STRING}-common" \
    "${VERSION_STRING}-curl" \
    "${VERSION_STRING}-dev" \
    "${VERSION_STRING}-fpm" \
    "${VERSION_STRING}-intl" \
    "${VERSION_STRING}-json" \
    "${VERSION_STRING}-mbstring" \
    "${VERSION_STRING}-mysql" \
    "${VERSION_STRING}-opcache" \
    "${VERSION_STRING}-soap" \
    "${VERSION_STRING}-sqlite3" \
    "${VERSION_STRING}-zip" \
    "${VERSION_STRING}-xml"

# These provide based on installed version.
apt-get --yes --force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install \
    php-mongodb php-apcu php-memcached php-pear php-redis

echo "[installing]::[composer]::[php.composer.sh]"
source ${INSTALL_DIR}/16/php.composer.sh

echo "[creating]::[${NGINX_USER}:${NGINX_GROUP} user|group|perms]"
source ${INSTALL_DIR}/common/container/create-user.sh "${NGINX_USER}:1000" "${NGINX_USER}:1000"

mkdir -p /var/log/nginx /var/www /srv
rm -Rf /var/www/html
chown root:${NGINX_GROUP} /var/log/nginx
chmod o-rwx /var/log/nginx
chown -R ${NGINX_USER}:${NGINX_GROUP} /var/www/ /srv/
mkdir /run/php