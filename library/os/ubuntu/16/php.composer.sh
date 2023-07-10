#!/usr/bin/env bash

# @TODO: Find a way to version pin the installer and perhaps get the hash dynamically.
#echo "[installing]::[php composer]"
#curl -s https://getcomposer.org/installer -o composer-setup.php
#
#COMPOSE_HASH="8a6138e2a05a8c28539c9f0fb361159823655d7ad2deecb371b04a83966c61223adc522b0189079e3e9e277cd72b8897"
#if ! sha384sum composer-setup.php | grep -q "${COMPOSE_HASH}" ; then
#    echo "[failed]::[to match composer hash]::[${COMPOSE_HASH}]"
#    exit 1
#fi

echo "[installing]::[php composer]"
curl -s https://getcomposer.org/installer -o composer-setup.php
EXPECTED_SIGNATURE="$(curl -s https://composer.github.io/installer.sig)"
if ! sha384sum composer-setup.php | grep -q "${EXPECTED_SIGNATURE}" ; then
    echo "[failed]::[to match composer hash]::[${EXPECTED_SIGNATURE}]"
    exit 1
fi

php composer-setup.php
rm composer-setup.php
mv composer.phar /usr/local/bin/composer
ln -s /usr/local/bin/composer /bin/composer