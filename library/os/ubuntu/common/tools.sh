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
    net-tools \
    wget \
    curl \
    python \
    ruby \
    lsof \
    mlocate \
    ca-certificates \
    cron \
    autofs \
    nfs-common \
    aufs-tools \
    jq \
    apparmor \
    rsyslog \
    python-setuptools \
    python-pip \
    supervisor \
    sysstat \
    nvme-cli


pip install awscli