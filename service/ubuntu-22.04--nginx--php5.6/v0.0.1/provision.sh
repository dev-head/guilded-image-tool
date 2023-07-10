#!/usr/bin/env bash

#######################################################################################################

CWD=`dirname $0`
INSTALL_DIR="/tmp/ubuntu"
UPLOAD_DIR="/tmp/upload"
CONFIG_DIR="${UPLOAD_DIR}/config"

# @description: Defined functions
# ----------------------------------------------------------------------------------------------------------------------
function provision_cleanup() {
    systemd-run --property="After=apt-daily.service apt-daily-upgrade.service" --wait /bin/true
    systemctl mask apt-daily.service apt-daily-upgrade.service || true
    rm -Rf /tmp/*
    apt autoclean || true
    apt autoremove || true
}

function provision_init(){
    echo "+{Running provision_init()}...."
    find "${INSTALL_DIR}" -name "*.sh" | xargs chmod +x
    echo "+{Completed provision_init()}...."
}

function provision_nginx(){
    source ${INSTALL_DIR}/22.04/nginx-php5.6.sh "www-data" "www-data"
    mv ${CONFIG_DIR}/nginx.conf /etc/nginx/nginx.conf
    mv ${CONFIG_DIR}/nginx-host /etc/nginx/sites-available/default
    mv ${CONFIG_DIR}/php.ini /etc/php/5.6/fpm/php.ini
    mv ${CONFIG_DIR}/php.cli.ini /etc/php/5.6/cli/php.ini
    mv ${CONFIG_DIR}/www.conf /etc/php/5.6/fpm/pool.d/www.conf

    echo "Configuring nginx"
    mkdir -p /var/www/public
    mv ${UPLOAD_DIR}/default.error.html /var/www/public/error.html
    mv ${UPLOAD_DIR}/default.index.php /var/www/public/index.php
    chown -R ${NGINX_USER}:${NGINX_GROUP} /var/www
    find /var/www -type d -exec chmod 750 {} \;
    find /var/www -type f -exec chmod 640 {} \;
    echo "upstream php-upstream { server 127.0.0.1:9005; }" > /etc/nginx/conf.d/upstream.conf
    service nginx restart
    service php5.6-fpm restart
}

function provision_install(){
    echo "+{Running provision_install()}...."
    provision_nginx
    echo "+{Completed provision_install()}+++++"
}

function provision_execute(){
    echo "+{ Starting provision_execute()....}"
    provision_init
    provision_install
    provision_cleanup
    echo "+{completed provision_execute()....}"
}


# @description: execute functionality.
# ----------------------------------------------------------------------------------------------------------------------

provision_execute
