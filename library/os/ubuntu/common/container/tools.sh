#!/usr/bin/env bash

set -e

apt-get install -y --no-install-recommends --no-install-suggests \
    adduser \
    apt-transport-https \
    software-properties-common \
    ca-certificates \
    curl \
    rsync
