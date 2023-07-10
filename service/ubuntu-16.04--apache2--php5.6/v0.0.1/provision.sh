#!/usr/bin/env bash

#
# Define local variables used in this provisioning script.
#

CWD=`dirname $0`
SCRIPTS_DIR="/tmp/ubuntu"
UPLOAD_DIR="/tmp/upload"
CONFIG_DIR="${UPLOAD_DIR}/config"
APACHE_USER="www-data"
APACHE_GROUP="www-data"

# ==> local: Uploading service/ubuntu-16.04--apache2--php5.6/v0.0.1/upload => /tmp/upload

pwd
ls -alih /tmp
echo "----------------------------------------------------------------------------"

ls -alih /tmp/ubuntu
echo "----------------------------------------------------------------------------"

ls -alih /tmp/upload
echo "----------------------------------------------------------------------------"

ls -alih /tmp/upload/upload
echo "----------------------------------------------------------------------------"

exit 1
echo "[SCRIPTS_DIR]::[${SCRIPTS_DIR}]"
ls -alih ${SCRIPTS_DIR}
echo "----------------------------------------------------------------------------"

echo "[UPLOAD_DIR]::[${UPLOAD_DIR}]"
ls -alih ${UPLOAD_DIR}
echo "----------------------------------------------------------------------------"

echo "[CONFIG_DIR]::[${CONFIG_DIR}]"
ls -alih ${CONFIG_DIR}
echo "----------------------------------------------------------------------------"

exit 1
#
# execute installs that are custom to this service
#
source ${SCRIPTS_DIR}/16/apache2-php5.6.sh "${APACHE_USER}" "${APACHE_GROUP}"

#
# Move uploaded files for configuraiton of this service.
#
mv ${CONFIG_DIR}/fpm.www.conf /etc/php/5.6/fpm/pool.d/www.conf
mv ${CONFIG_DIR}/apache.security.conf  /etc/apache2/conf-available/zz-99-apache.security.conf
mv ${CONFIG_DIR}/apache.org.conf  /etc/apache2/conf-available/zz-99-apache.org.conf
mv ${CONFIG_DIR}/apache.php.conf  /etc/apache2/conf-available/zz-99-apache.php.conf
mv ${CONFIG_DIR}/apache.mpm_event.conf  /etc/apache2/mods-available/mpm_event.conf
mv ${CONFIG_DIR}/apache.vhost.conf /etc/apache2/sites-available/000-default.conf
mv ${CONFIG_DIR}/php.ini /etc/php/5.6/fpm/php.ini
mv ${CONFIG_DIR}/cli.ini /etc/php/5.6/cli/php.ini

#
# Update permissions, create directories required for this service.
#
mkdir -p /srv/default/www
mv ${UPLOAD_DIR}/default.index.html /srv/default/www/error.html
chown -R ${APACHE_USER}:${APACHE_GROUP} /srv /var/www
find /var/www -type d -exec chmod 750 {} \;
find /var/www -type f -exec chmod 640 {} \;

#
# Add any remaining customizations for this service.
# - custom php, apache configs and modules enabled.
#
a2disconf php5.6-fpm
a2enconf zz-99-apache.security zz-99-apache.ue zz-99-apache.php
