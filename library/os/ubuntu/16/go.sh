#!/usr/bin/env bash

export export SERVICE_USER="${1:-root}"  && \
    export SERVICE_GROUP="${2:-root}" && \
    export BUILD_LANG="${BUILD_LANG:-go}" && \
    export BUILD_LANG_VERSION="${BUILD_VERSION:-BUILD_LANG_VERSION}"
    export BUILD_LANG_VERSION="${BUILD_LANG_VERSION:-1.12.4}"  && \
    export VERSION_STRING="${BUILD_LANG}${BUILD_LANG_VERSION}"  && \
    export LANG_SHA256="${LANG_SHA256:-d7d1f1f88ddfe55840712dc1747f37a790cbcaa448f6c9cf51bbe10aa65442f5}" && \
    export WORKING_DIR="${WORKING_DIR:-/go}" && \
    export DEBIAN_FRONTEND=noninteractive && \
    export DPKG_ARCH=$(dpkg --print-architecture)

echo "[BUILD_LANG]::[${BUILD_LANG}]"     && \
    echo "[BUILD_LANG_VERSION]::[${BUILD_LANG_VERSION}]"  && \
    echo "[VERSION_STRING]::[${VERSION_STRING}]"  && \
    echo "[WORKING_DIR]::[${WORKING_DIR}]"  && \
    echo "[LANG_SHA256]::[${LANG_SHA256}]"  && \
    echo "[DPKG_ARCH]::[${DPKG_ARCH}]"

echo "[INSTALLING]::[${BUILD_LANG_VERSION}]"

apt-get update

echo "[creating]::[${SERVICE_USER}:${SERVICE_GROUP} user|group|perms]"
source ${INSTALL_DIR}/common/container/create-user.sh "${SERVICE_USER}:1000" "${SERVICE_GROUP}:1000"

#
# Install [LANGUAGE]
# -------------------------------------------------------------------------------------------------------------------- #
mkdir -p /tmp/install.golang
cd /tmp/install.golang
echo "[DOWNLOAD]::[https://dl.google.com/go/go${BUILD_LANG_VERSION}.linux-${DPKG_ARCH}.tar.gz]"
curl -o go.tgz https://dl.google.com/go/go${BUILD_LANG_VERSION}.linux-${DPKG_ARCH}.tar.gz


# Verify checksum of installation.
echo "${LANG_SHA256} go.tgz" | sha256sum -c -
if [ $? != 0 ]; then echo "[FAILED]::[CHECKSUM]::[go.tgz]::[${LANG_SHA256}](!=)[$(sha256sum go.tgz)]"; exit 1; fi
tar -C /usr/local -xzf go.tgz
export GOPATH="${WORKING_DIR}"
export PATH=$GOPATH/bin:$PATH:/usr/local/go/bin
echo "GOPATH=${WORKING_DIR}"                    | tee -a /etc/default/golang
echo "GOCACHE=${WORKING_DIR}/cache"             | tee -a /etc/default/golang
echo "GOPATH=${WORKING_DIR}"                    | tee -a /etc/profile
echo "GOCACHE=${WORKING_DIR}/cache"             | tee -a /etc/profile
echo 'PATH=$GOPATH/bin:$PATH:/usr/local/go/bin' | tee -a /etc/profile

# ^ paths not working

go version
cd /
rm -Rf /tmp/install.golang

# Configure [LANGUAGE]
mkdir -p "${WORKING_DIR}/src" "${WORKING_DIR}/bin" "${WORKING_DIR}/cache"
chmod -R 777 "${WORKING_DIR}"
chmod o-rwx "${WORKING_DIR}"
chown -R ${SERVICE_USER}:${SERVICE_GROUP} "${WORKING_DIR}"
