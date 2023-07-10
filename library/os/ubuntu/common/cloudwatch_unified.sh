#!/usr/bin/env bash

#
# @description: Defined variables
# @NOTE This script is designed to download the latest cloud watch agent; this poses risks you should already understand.
#
# ----------------------------------------------------------------------------------------------------------------------
DEB_LINK="https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb"
DEB_SIG="https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb.sig"
GPG_PUB="https://s3.amazonaws.com/amazoncloudwatch-agent/assets/amazon-cloudwatch-agent.gpg"
WORK_DIR="/tmp/install_cloudwatch_logs"

# @description: Defined functions
# ----------------------------------------------------------------------------------------------------------------------
function init(){
    echo "[creating workspace]::[${WORK_DIR}]"
    mkdir -p "${WORK_DIR}"; cd "${WORK_DIR}"
    if [[ -f /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl ]]; then echo "cloudwatch agent installed"; exit 0; fi
}

function cleanup(){

    if [[ ! -f /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl ]]; then
        echo "[failed to install cloud watch]"
        exit 2
    fi

    if [[ -d "${WORK_DIR}" ]]; then
        echo "[removing workspace]::[${WORK_DIR}]"
        cd /tmp;
        rm -Rf "${WORK_DIR}"
    fi
}

function downloadInstall(){
    echo "[$0]::[downloadInstall()]::[started]"
    curl -L "${DEB_LINK}" -O
    curl -L "${DEB_SIG}" -O
    curl -L "${GPG_PUB}" -O
    echo "[$0]::[downloadInstall()]::[completed]"
}

function verifyDownload(){
    echo "[$0]::[verifyDownload()]::[started]"
    gpg --import amazon-cloudwatch-agent.gpg
    if [ "$?" != 0 ]; then echo "[failed to import cloudwatch key]::[amazon-cloudwatch-agent.gpg]"; exit 2; fi
    key=$(gpg --import amazon-cloudwatch-agent.gpg  2>&1 | grep "gpg: key" | cut -d ' ' -f 3 | cut -d ':' -f 1)

    gpg --fingerprint "${key}"
    if [ "$?" != 0 ]; then echo "[failed to verify signigure cloudwatch key]::[${key}]"; exit 2; fi

    gpg --verify amazon-cloudwatch-agent.deb.sig amazon-cloudwatch-agent.deb
    if [ "$?" != 0 ]; then echo "[failed to verify signigure cloudwatch key]::[amazon-cloudwatch-agent.deb]"; exit 2; fi
    echo "[$0]::[verifyDownload()]::[completed]"
}

function install(){
    dpkg -i -E ./amazon-cloudwatch-agent.deb
}

function execute() {
    echo "[$0]::[execute()]::[started]"
    init
    downloadInstall
    verifyDownload
    install
    cleanup
    echo "[$0]::[execute()]::[completed]"
}

# @description: execute functionality.
# ----------------------------------------------------------------------------------------------------------------------

echo "+{ Starting execute()....}"
execute
echo "+{completed execute()....}"
