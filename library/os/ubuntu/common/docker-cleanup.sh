#!/usr/bin/env bash

SUDO_FORCE_REMOVE=yes apt-get remove -ym \
    sudo \
    vim \
    unzip \
    dirmngr

apt-get autoclean
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
