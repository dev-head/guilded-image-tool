#!/usr/bin/env bash

# based on: (https://websiteforstudents.com/installing-the-latest-python-3-7-on-ubuntu-16-04-18-04)

PYTHON_VERSION="${1:-3.7.4}"
NUM_CPU_CORES_IN_BUILD_MACHINE="${2:-6}"
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# install python build tools.
apt-get update && apt-get --yes --force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install \
    build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev

cd /tmp
curl -o python.tar.xz https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz
curl -o python.tar.asc https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz.asc
tar -xf python.tar.xz
cd Python-${PYTHON_VERSION}
./configure --enable-optimizations
make -j ${NUM_CPU_CORES_IN_BUILD_MACHINE}
make install

# uninstall python build tools.
apt-get remove -ym \
    build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev