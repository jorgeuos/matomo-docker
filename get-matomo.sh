#!/bin/bash
# From orginal Dockerfile
# We use this script so we can use env vars in a single place

set -ex

# Ignore schellcheck nag
# shellcheck source=/dev/null
. ./set-envvars.sh


fetchDeps="
    dirmngr
    gnupg
"

apt-get update
apt-get install -y --no-install-recommends $fetchDeps

curl -fsSL -o matomo.tar.gz "https://builds.matomo.org/matomo-${MATOMO_VERSION}.tar.gz"
curl -fsSL -o matomo.tar.gz.asc "https://builds.matomo.org/matomo-${MATOMO_VERSION}.tar.gz.asc"

export GNUPGHOME="$(mktemp -d)"

gpg --batch --keyserver keyserver.ubuntu.com --recv-keys F529A27008477483777FC23D63BB30D0E5D2C749
gpg --batch --verify matomo.tar.gz.asc matomo.tar.gz

gpgconf --kill all

rm -rf "$GNUPGHOME" matomo.tar.gz.asc
tar -xzf matomo.tar.gz -C /usr/src/

rm matomo.tar.gz
apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $fetchDeps

rm -rf /var/lib/apt/lists/*
