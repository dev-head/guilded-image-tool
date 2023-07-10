#!/usr/bin/env bash

set -e

apt-get autoclean || true
apt-get autoremove -y --purge || true
apt-get clean || true

rm -f /var/log/apt/*
rm -f /var/log/dpkg.log
rm -f /var/cache/debconf/*-old
rm -rf /var/lib/apt/lists/*
mkdir -p /var/lib/apt/lists/partial

