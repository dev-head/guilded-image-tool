#!/usr/bin/env bash

INSTALL_DIR=${PROVISIONING_LIB:-/tmp}

set -e

if [[ -d "${INSTALL_DIR}/root" ]]; then
    echo "[RSYNC]::[${INSTALL_DIR}/root]->[/]"
    rsync -vrulA ${INSTALL_DIR}/root/ /
fi