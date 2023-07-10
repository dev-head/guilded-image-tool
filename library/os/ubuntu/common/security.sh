#!/usr/bin/env bash
echo "Provisioning with shell security.sh"

apt-cache policy
apt-get update

echo "[enable]::[services]"
ENABLED_SERVICES="rsyslog cron"
for en_service in ${ENABLED_SERVICES}; do
    if [ "$(systemctl is-enabled ${en_service} 2>/dev/null)" != "enabled" ]; then systemctl enable ${en_service}; else echo "[${en_service}]::[enabled]"; fi
done
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


echo "[enable]::[packages]"
ENABLED_PACKAGES="ssh tcpd aide libpam-pwquality"
for en_package in ${ENABLED_PACKAGES}; do
    if [ "$(systemctl is-enabled ${en_package} 2>/dev/null)" != "enabled" ]; then DEBIAN_FRONTEND=noninteractive apt-get install -y ${en_package}; else echo "[${en_package}]::[installed]"; fi
done
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

echo "[disable]::[services]"
DISABLED_SERVICES="slapd nfs-server rpcbind bind9 vsftpd rsync snmpd squid smbd dovecot isc-dhcp-server \
  isc-dhcp-server6 cups avahi-daemon apache2 nis"

for dis_service in ${DISABLED_SERVICES}; do
    if [ "$(systemctl is-enabled ${dis_service} 2>/dev/null)" == "enabled" ]; then systemctl disable ${dis_service}; else echo "[${dis_service}]::[disabled]"; fi
done
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


echo "[disable]::[packages]"
DISABLED_PACKAGES="nis telnet rsh-client rsh-redone-client talk ldap-utils"
for dis_package in ${DISABLED_PACKAGES}; do
    dpkg -s "${dis_package}" &>/dev/null && apt-get remove "${dis_package}" || echo "[${dis_package}]::[not-installed]"
done
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

echo "[configure]::[aide]"
# /etc/default/aide
sudo aideinit -f -y
cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db
sudo update-aide.conf
cp /var/lib/aide/aide.conf.autogenerated /etc/aide/aide.conf

#### Black list some directories.
echo '!/var/lib/lxcfs/cgroup/memory/*' | tee -a /etc/aide/aide.conf
echo '!/var/lib/lxcfs/cgroup/devices/*' | tee -a /etc/aide/aide.conf
echo '!/var/lib/lxcfs/cgroup/blkio/*' | tee -a /etc/aide/aide.conf
echo '!/var/log/*' | tee -a /etc/aide/aide.conf
echo '!/var/spool/*' | tee -a /etc/aide/aide.conf
echo '!/mnt/' | tee -a /etc/aide/aide.conf

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

echo "[configure]::[cron]"
cat > /etc/cron.d/aide << EOM
SHELL=/bin/sh
PATH=/sbin:/bin
0 5 * * * root /usr/bin/aide --config /etc/aide/aide.conf --check
EOM
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

echo "[configure]::[ssh]"
echo "MaxAuthTries 4" | tee -a /etc/ssh/sshd_config
echo "PermitUserEnvironment no" | tee -a /etc/ssh/sshd_config
echo "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com" | tee -a /etc/ssh/sshd_config
echo "ClientAliveInterval 300" | tee -a /etc/ssh/sshd_config
echo "ClientAliveCountMax 3" | tee -a /etc/ssh/sshd_config
echo "MaxAuthTries 3" | tee -a /etc/ssh/sshd_config
echo "MaxSessions 5" | tee -a /etc/ssh/sshd_config
echo "PermitRootLogin no" | tee -a /etc/ssh/sshd_config
echo "TCPKeepAlive no" | tee -a /etc/ssh/sshd_config
echo "AllowGroups ubuntu dev devops root" | tee -a /etc/ssh/sshd_config
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/LoginGraceTime 120/LoginGraceTime 60/g' /etc/ssh/sshd_config
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

echo "[configure]::[pam]"
cat > /etc/login.group.allowed << EOM
ubuntu
EOM

cat > /etc/security/pwquality.conf << EOM
minlen = 14
dcredit = -1
ucredit = -1
ocredit = -1
lcredit = -1
EOM
echo "auth required pam_tally2.so onerr=fail audit silent deny=5 unlock_time=900" | tee -a /etc/pam.d/common-auth
echo "auth required pam_listfile.so onerr=fail item=group sense=allow file=/etc/login.group.allowed" | tee -a /etc/pam.d/common-auth
echo "password required pam_pwhistory.so remember=5" | tee -a /etc/pam.d/common-password
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

echo "[configure]::[users]"
sed -i 's/PASS_MAX_DAYS   99999/PASS_MAX_DAYS   185/g' /etc/login.defs
sed -i 's/PASS_MIN_DAYS   0/PASS_MIN_DAYS   7/g' /etc/login.defs
useradd -D -f 30
echo "umask 027" | tee -a /etc/bash.bashrc
echo "TMOUT=600" | tee -a /etc/profile
echo "auth required pam_wheel.so" | tee -a /etc/pam.d/su
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


echo "[configure]::[misc]"
echo "kernel.randomize_va_space = 2" | tee -a /etc/sysctl.d/10-kernel-hardening.conf

cat > /etc/sysctl.d/99-sysctl.conf << EOM
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_syncookies = 1
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOM

sysctl -w kernel.randomize_va_space=2
sysctl -w net.ipv4.ip_forward=0
sysctl -w net.ipv4.conf.all.send_redirects=0
sysctl -w net.ipv4.conf.default.send_redirects=0
sysctl -w net.ipv4.conf.all.accept_source_route=0
sysctl -w net.ipv4.conf.default.accept_source_route=0
sysctl -w net.ipv4.conf.all.accept_redirects=0
sysctl -w net.ipv4.conf.default.accept_redirects=0
sysctl -w net.ipv4.conf.all.secure_redirects=0
sysctl -w net.ipv4.conf.default.secure_redirects=0
sysctl -w net.ipv4.conf.all.log_martians=1
sysctl -w net.ipv4.conf.default.log_martians=1
sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1
sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1
sysctl -w net.ipv4.conf.all.rp_filter=1
sysctl -w net.ipv4.conf.default.rp_filter=1
sysctl -w net.ipv4.tcp_syncookies=1
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -w net.ipv6.conf.lo.disable_ipv6=1
sysctl -w net.ipv4.route.flush=1
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

echo "[configure]::[permissions]"
chown root:shadow /etc/shadow
chmod o-rwx,g-wx /etc/shadow
chown root:root /etc/group
chmod 644 /etc/group
chown root:shadow /etc/gshadow
chmod o-rwx,g-rw /etc/gshadow
chown root:root /etc/passwd-
chmod u-x,go-wx /etc/passwd-
chown root:root /etc/shadow-
chown root:shadow /etc/shadow-
chmod o-rwx,g-rw /etc/shadow-
chown root:root /etc/group-
chmod u-x,go-wx /etc/group-
chown root:root /etc/gshadow-
chown root:shadow /etc/gshadow-
chmod o-rwx,g-rw /etc/gshadow-

# Remove any world writeable file permissions
WW_FILES=$(df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type f -perm -0002)
if [ ! -z "${WW_FILES}" ]; then
    for FILE in ${WW_FILES}; do
        echo "[removing world writeable]::[${FILE}]"
        chmod o-w "${FILE}"
    done
fi
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

# install RDS Certs
curl -o /etc/ssl/certs/rds-combined-ca-bundle.pem https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem