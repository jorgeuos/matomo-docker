#!/bin/bash
# From orginal Dockerfile
# We use this script so we can use env vars in a single place

set -ex

# Ignore schellcheck nag
# shellcheck source=/dev/null
. ./set-envvars.sh

apk add --no-cache --virtual .fetch-deps gnupg

curl -fsSL -o matomo.tar.gz "https://builds.matomo.org/matomo-${MATOMO_VERSION}.tar.gz"
curl -fsSL -o matomo.tar.gz.asc "https://builds.matomo.org/matomo-${MATOMO_VERSION}.tar.gz.asc"

export GNUPGHOME="$(mktemp -d)"

gpg --batch --keyserver keyserver.ubuntu.com --recv-keys F529A27008477483777FC23D63BB30D0E5D2C749
gpg --batch --verify matomo.tar.gz.asc matomo.tar.gz

gpgconf --kill all

rm -rf "$GNUPGHOME" matomo.tar.gz.asc

# tar -xzf matomo.tar.gz -C /usr/src/
tar -xzf matomo.tar.gz -C /var/www/html/
rm matomo.tar.gz
apk del .fetch-deps
