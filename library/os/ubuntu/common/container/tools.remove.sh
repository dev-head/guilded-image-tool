#!/usr/bin/env bash

set -e

export DEBIAN_FRONTEND=noninteractive

#
# CIS::Docker::4.3
#
SUDO_FORCE_REMOVE=yes apt-get remove -ym  --allow-remove-essential \
    software-properties-common \
    rsync

# removing adduser causes apt-get to flag apt for removal, need to figure out why.

# might want to run these on their own to better handle exceptions.
# apt-get remove software-properties-common
# apt-get remove adduser
# apt-get remove passwd
# apt-get remove rsync

