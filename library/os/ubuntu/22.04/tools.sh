#!/usr/bin/env bash

echo "Provisioning with shell script: tools.sh"
export DEBIAN_FRONTEND=noninteractive
apt-get install -y --no-install-recommends --no-install-suggests \
    apt-transport-https \
    software-properties-common \
    sudo \
    vim \
    unzip \
    htop \
    iftop \
    iotop \
    ntp \
    nmap \
    dirmngr \
    git \
    wget \
    curl \
    python3 \
    ruby \
    lsof \
    mlocate \
    ca-certificates \
    cron \
    autofs \
    nfs-common \
    jq \
    apparmor \
    rsyslog \
    python-setuptools \
    python-pip \
    supervisor \
    sysstat \
    nvme-cli \
    net-tools \
    gpg \
    gpg-agent \
    apt-utils \
    awscli