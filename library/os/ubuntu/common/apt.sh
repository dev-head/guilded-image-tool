#!/usr/bin/env bash

SLEEP=${1:-5}
sleep ${SLEEP}

while : ; do
    sleep 1
    echo $( ps aux | grep -c lock_is_held ) processes are using apt.
    ps aux | grep -i apt
    [[ $( ps aux | grep -c lock_is_held ) > 1 ]] || break
done

apt-get update
apt-cache policy
apt-get dist-upgrade