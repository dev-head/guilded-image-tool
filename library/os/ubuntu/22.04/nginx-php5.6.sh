#!/usr/bin/env bash

NGINX_USER="${1:-www-data}"
NGINX_GROUP="${2:-www-data}"

##--------------------------------------------------------------------------------------------------------------------##

export DEBIAN_FRONTEND=noninteractive
echo "[install]::[dependency packages]"
apt-get update
apt-get install -y --no-install-recommends --no-install-suggests \
    gpg-agent vim wget language-pack-en-base software-properties-common curl \
    git unzip zlib1g-dev libpng-dev net-tools mysql-client \
    libmcrypt-dev libssl-dev build-essential libz-dev libpcre3 libpcre3-dev \
    openjdk-8-jdk ruby ruby-dev rsyslog libzip-dev libpng-dev

echo "[install]::[runtime packages]"
LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
apt-get update
apt-get install -y --no-install-recommends --no-install-suggests \
    php5.6 php5.6-fpm php5.6-curl php5.6-mysql php5.6-dev php5.6-soap \
    php5.6-xml php5.6-mcrypt php5.6-bcmath php5.6-mbstring php5.6-mongodb \
    php5.6-common php5.6-apcu php5.6-memcached php5.6-redis php5.6-imagick \
    nginx nginx-extras

# WARNING: if you install this with the others, latest php vesrion gets selected.
apt-get install --no-install-recommends --no-install-suggests \
   php-pear

##--------------------------------------------------------------------------------------------------------------------##

echo "[installing]::[sass compass php]"
gem install sass compass -n /usr/local/bin
ln -s /usr/local/bin/sass /usr/bin/sass
ln -s /usr/local/bin/compass /usr/bin/compass

##--------------------------------------------------------------------------------------------------------------------##

echo "[installing]::[php composer]"
curl -s https://getcomposer.org/installer -o composer-setup.php
EXPECTED_SIGNATURE="$(curl -s https://composer.github.io/installer.sig)"
if ! sha384sum composer-setup.php | grep -q "${EXPECTED_SIGNATURE}" ; then
    echo "[failed]::[to match composer hash]::[${EXPECTED_SIGNATURE}]"
    exit 1
fi

echo "[configuring]::[php composer]"
php composer-setup.php
rm composer-setup.php
mv composer.phar /usr/local/bin/composer
ln -s /usr/local/bin/composer /bin/composer

##--------------------------------------------------------------------------------------------------------------------##

echo "[creating]::[${NGINX_USER}:${NGINX_GROUP} user|group|perms]"
mkdir -p /var/log/nginx /var/www /srv
rm -Rf /var/www/html
chown root:${NGINX_GROUP} /var/log/nginx
chmod o-rwx /var/log/nginx
chown ${NGINX_USER}:${NGINX_GROUP} /var/www/ /srv/

# Hack for php service alias support
echo "Alias=php5-fpm.service" | sudo tee -a /lib/systemd/system/php5.6-fpm.service
sudo systemctl daemon-reload
sudo systemctl reenable /lib/systemd/system/php5.6-fpm.service

service nginx restart
service php5.6-fpm restart