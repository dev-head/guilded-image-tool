#!/usr/bin/env bash

APACHE_USER="${1:-www-data}"
APACHE_GROUP="${2:-www-data}"

groupadd -r ${APACHE_GROUP}
useradd ${APACHE_USER} -r -g ${APACHE_GROUP} -d /var/www -s /sbin/nologin

##--------------------------------------------------------------------------------------------------------------------##

export DEBIAN_FRONTEND=noninteractive
echo "[install]::[dependency packages]"
apt-get update
apt-get install -y --no-install-recommends --no-install-suggests \
    vim wget language-pack-en-base software-properties-common curl \
    git unzip zlib1g-dev libpng-dev net-tools mysql-client \
    libmcrypt-dev libssl-dev build-essential libz-dev libpcre3 libpcre3-dev \
    openjdk-8-jdk ruby ruby-dev rsyslog libzip-dev libpng-dev

echo "[install]::[runtime packages]"
LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/apache2
LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
apt-get update
apt-get install -y --no-install-recommends --no-install-suggests \
    apache2   libapache2-mod-security2 libapache2-mod-apparmor \
    php5.6 php5.6-fpm php5.6-curl php5.6-mysql php5.6-dev \
    php5.6-xml php5.6-mcrypt php5.6-bcmath php5.6-mbstring php5.6-soap \
    php5.6-dba php5.6-bz2 php5.6-zip

# WARNING: if you install this with the others, php7 gets selected.
apt-get install -y --no-install-recommends --no-install-suggests \
    php-mongo php-apcu php-memcached php-pear php-redis php-imagick

echo "[configure]::[apache/php modules]"
a2enconf php5.6-fpm
a2enmod rewrite headers proxy proxy_fcgi proxy_http expires setenvif apparmor proxy mpm_event
a2dismod -f status authn_file authz_host authz_user autoindex proxy_http mpm_prefork mpm_worker
service apache2 restart

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

echo "[creating]::[${APACHE_USER}:${APACHE_GROUP} user|group|perms]"
mkdir -p /var/log/apache2 /var/www /srv
rm -Rf /var/www/html
chown root:${APACHE_GROUP} /var/log/apache2
chmod o-rwx /var/log/apache2
chown ${APACHE_USER}:${APACHE_GROUP} /var/www/ /srv/

# Hack for php service alias support
# doing this to be backwards compat with existing build.
echo "Alias=php5-fpm.service" | sudo tee -a /lib/systemd/system/php5.6-fpm.service
sudo systemctl daemon-reload
sudo systemctl reenable /lib/systemd/system/php5.6-fpm.service

service apache2 restart
service php5.6-fpm restart