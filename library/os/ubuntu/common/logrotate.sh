#!/usr/bin/env bash

echo "Provisioning with shell script: logrotate.sh"
if [[ $(which logrotate) ]]; then
    echo "Logrotate already installed"
else
    apt-get update
    apt-get install -y logrotate
fi

touch /etc/logrotate.d/app.logs
cat << EOF > /etc/logrotate.d/app.logs
/var/log/app/prod.log
{
  compress
  daily
  delaycompress
  missingok
  rotate 5
}
EOF