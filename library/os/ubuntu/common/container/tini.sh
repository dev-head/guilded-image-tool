#!/usr/bin/env bash

set -e

# Install Tini.
TINI_VERSION="${1:-v0.18.0}"
GPG_KEY=595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7

curl -fsSL "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini" -o /tini
curl -fsSL "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc" -o /tini.asc
export GNUPGHOME="$(mktemp -d)"

# gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys ${GPG_KEY}

( gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "${GPG_KEY}" \
  || gpg --keyserver pgp.mit.edu --recv-keys "${GPG_KEY}" \
  || gpg --keyserver keyserver.pgp.com --recv-keys "${GPG_KEY}" )


gpg --batch --verify /tini.asc /tini

if [[ "$?" != 0 ]]; then
    echo "[FAILED]::[INSTALL]::[TINI]"
    exit 1
fi

rm -rf "$GNUPGHOME" /tini.asc
chmod +x /tini