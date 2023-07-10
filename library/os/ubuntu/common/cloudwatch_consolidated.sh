#!/usr/bin/env bash

echo "Provisioning with shell script: cloudwatch_consolidated.sh"

if [[ -f /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl ]]; then echo "cloudwatch agent installed"; exit 0; fi
mkdir -p /tmp/install_cloudwatch_logs
cd /tmp/install_cloudwatch_logs
curl -L https://s3.amazonaws.com/amazoncloudwatch-agent/linux/amd64/latest/AmazonCloudWatchAgent.zip -O
unzip AmazonCloudWatchAgent.zip


if [[ ! -f "AmazonCloudWatchAgent.zip" ]]; then
    echo "==> ERROR: Failed to download [AmazonCloudWatchAgent.zip]"
    exit 1
fi

sudo ./install.sh

cd /tmp
rm -Rf /tmp/install_cloudwatch_logs