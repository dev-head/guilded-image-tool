#!/usr/bin/env bash

APP_USER=${1:-application}

# i don't think anyone is using this.
exit 1

set -e


echo "[PROVISION]::[${APP_USER}]"

# change the docker user, we want to have an application user.
if [ $(grep docker:x:1000 /etc/passwd) ]; then
    echo "moving docker user id so we can create our own."
    usermod -u 1003 docker
fi

if [ $(grep docker:x:1000 /etc/group) ]; then
    echo "moving docker group id so we can create our own."
    groupmod -g 1003 docker
fi


# create an application user/group.
addgroup --gid 1000 ${APP_USER}
useradd -s /sbin/nologin --create-home --system --uid 1000 -g 1000 ${APP_USER}
usermod -G staff ${APP_USER}
