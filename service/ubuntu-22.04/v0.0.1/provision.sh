#!/usr/bin/env bash

#######################################################################################################

CWD=`dirname $0`
INSTALL_DIR="/tmp/ubuntu"


# @description: Defined functions
# ----------------------------------------------------------------------------------------------------------------------
function provision_cleanup() {
    systemd-run --property="After=apt-daily.service apt-daily-upgrade.service" --wait /bin/true
    systemctl mask apt-daily.service apt-daily-upgrade.service || true
    rm -Rf /tmp/*
    apt autoclean || true
    apt autoremove || true
}

function provision_configureCloudWatch() {
    mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/
    mv /tmp/upload/amazon-cloudwatch-agent.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
    chown root:root /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a stop || true
    jq ".metrics.namespace = \"${PLATFORM}/${ENVIRONMENT}-${PROJECT}\" | .logs.logs_collected.files.collect_list[].log_group_name = \"${PLATFORM}-${ENVIRONMENT}-${PROJECT}\"" /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.compiled.json
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.compiled.json -s

}

function provision_init(){
    echo "+{Running provision_init()}...."
    find "${INSTALL_DIR}" -name "*.sh" | xargs chmod +x
    echo "+{Completed provision_init()}...."
}

function provision_mod(){
  echo "+{Running provision_mod()}...."
  mv /tmp/upload/motd.asc.md /etc/update-motd.d/motd.asc

cat << 'EOM' > /etc/update-motd.d/99-banner
#!/bin/sh
printf "\n$(cat /etc/update-motd.d/motd.asc)\n"
EOM

  chmod -R 755 /etc/update-motd.d/
  chown -R root:root /etc/update-motd.d/

  echo "+{Completed provision_mod()}...."
}

function provision_install(){
    echo "+{Running provision_install()}...."
    ${INSTALL_DIR}/common/users.sh
    ${INSTALL_DIR}/common/security.sh
    ${INSTALL_DIR}/common/ssm.sh
    ${INSTALL_DIR}/common/cloudwatch_unified.sh
    ${INSTALL_DIR}/22.04/code-deploy.sh disabled 1.4.1-2244
    curl -o /etc/ssl/certs/rds-combined-ca-bundle.pem https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem
    echo "+{Completed provision_install()}+++++"
}

function provision_execute(){
    echo "+{ Starting provision_execute()....}"
    provision_init
    provision_install
    provision_configureCloudWatch
    provision_mod
    provision_cleanup
    echo "+{completed provision_execute()....}"
}


# @description: execute functionality.
# ----------------------------------------------------------------------------------------------------------------------

provision_execute
