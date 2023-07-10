#!/usr/bin/env bash

#DEFAULT_USER="${1:-docker}"
#DEFAULT_GROUP="${2:-$DEFAULT_USER}"
#groupadd ${DEFAULT_GROUP}
#useradd -d /home/${DEFAULT_USER} -g "${DEFAULT_GROUP}" -m -s /bin/bash ${DEFAULT_USER}

#
# CIS::Docker::4.2
# find / -group adm
#
deluser daemon      || true
deluser bin         || true
deluser sys         || true
deluser sync        || true
deluser games       || true
deluser man         || true
deluser lp          || true
deluser mail        || true
deluser news        || true
deluser uucp        || true
deluser proxy       || true
deluser backup      || true
deluser list        || true
deluser irc         || true
deluser gnats       || true

delgroup disk       || true
delgroup kmem       || true
delgroup dialout    || true
delgroup fax        || true
delgroup voice      || true
delgroup cdrom      || true
delgroup floppy     || true
delgroup tape       || true
delgroup audio      || true
delgroup dip        || true
delgroup operator   || true
delgroup src        || true
delgroup video      || true
delgroup sasl       || true
delgroup plugdev    || true
delgroup users      || true
delgroup netdev     || true
delgroup ssh        || true