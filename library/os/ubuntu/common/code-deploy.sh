#!/usr/bin/env bash

ON_START=${1:-"false"}

#
# WARNING :: code deploy may run before cloud init on an EC2 instance, causing issues with installations.
#
echo "[provisioning with shell script]::[$0]"

# REF: https://docs.aws.amazon.com/codedeploy/latest/userguide/resource-kit.html#resource-kit-bucket-names
BUCKET_NAME=${2:-aws-codedeploy-us-east-1}

if [[ -f /etc/init.d/codedeploy-agent ]]; then echo "codedeploy-agent installed"; exit 0; fi

export DEBIAN_FRONTEND=noninteractive
apt-get install -y --no-install-recommends --no-install-suggests ruby

cd /tmp
curl -L -o install https://${BUCKET_NAME}.s3.amazonaws.com/latest/install

if [[ ! -f "install" ]]; then
    echo "==> ERROR: Failed to download [https://${BUCKET_NAME}.s3.amazonaws.com/latest/install]"
    exit 1
fi

chmod +x ./install
./install auto
service codedeploy-agent status

if [ "${ON_START}" = "disabled" ]; then
  echo "[disabling code deploy on start]"
  update-rc.d codedeploy-agent remove || true
fi