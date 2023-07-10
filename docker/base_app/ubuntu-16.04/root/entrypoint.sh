#!/usr/bin/env sh

setHostname() {
    _HOSTNAME=""
    # We're in ECS land, lets get funky
    if [[ ! -z "${ECS_CONTAINER_METADATA_FILE}" ]]; then
        _HOSTNAME=$(curl -s -XGET http://169.254.169.254/latest/meta-data/local-hostname)
    else
        _HOSTNAME=${HOSTNAME:-$(hostname)}
    fi
    hostname ${_HOSTNAME}
    echo "[hostname]::[${_HOSTNAME}]"
}

#
# Main bootstrap init function.
#
init() {
    setHostname
}

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "starting up container for service"
echo "[CMD]::[$@]"
init

exec $@