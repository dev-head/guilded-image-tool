#!/usr/bin/env bash

export BUILD_LANG="php" && \
    export BUILD_LANG_VERSION="${1:-7.2}"  && \
    export VERSION_STRING="${BUILD_LANG}${BUILD_LANG_VERSION}"  && \
    export APACHE_USER="${2:-www-data}"  && \
    export APACHE_GROUP="${3:-www-data}" && \
    export DEBIAN_FRONTEND=noninteractive

echo "[BUILD_LANG]::[${BUILD_LANG}]"     && \
    echo "[BUILD_LANG_VERSION]::[${BUILD_LANG_VERSION}]"  && \
    echo "[VERSION_STRING]::[${VERSION_STRING}]"  && \
    echo "[APACHE_USER]::[${APACHE_USER}]"  && \
    echo "[APACHE_GROUP]::[${APACHE_GROUP}]"xml

# Add third party repos
LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/apache2

# Install stuff
echo "Installing [${VERSION_STRING}] and apache"
apt-get update

# Install Webserver
apt-get --yes --force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install \
    apache2

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
    php-mongodb php-apcu php-memcached php-pear php-redis php-msgpack

# Enable modules
phpenmod msgpack igbinary

# Install AWS Memcached Client
source ${INSTALL_DIR}/16/php-memcached-aws.sh ${BUILD_LANG_VERSION}

echo "[installing]::[composer]::[php.composer.sh]"
source ${INSTALL_DIR}/16/php.composer.sh

echo "[creating]::[${APACHE_USER}:${APACHE_GROUP} user|group|perms]"
source ${INSTALL_DIR}/common/container/create-user.sh "${APACHE_USER}:1000" "${APACHE_GROUP}:1000"

rm -Rf /var/www/html
mkdir -p /var/www /srv /run/php
chown -R ${APACHE_USER}:${APACHE_GROUP} /var/www/ /srv/
