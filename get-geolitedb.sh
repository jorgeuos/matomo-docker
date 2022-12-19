#!/bin/bash
set -ex

# Ignore schellcheck nag
# shellcheck source=/dev/null
. ./set-envvars.sh

cd /var/www/html

export MAXMIND_URL="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=${MAXMIND_LICENSE_KEY}&suffix=tar.gz"

ls -lah /tmp
curl "$MAXMIND_URL" -o /tmp/GeoLite2-City.tar.gz
ls -lah /tmp
cd /tmp && tar xvf /tmp/GeoLite2-City.tar.gz
ls -lah /tmp/GeoLite2-City*/
mkdir -p /var/www/html/misc
ls -lah /var/www/html/misc/
mv /tmp/GeoLite2-City*/GeoLite2-City.mmdb /var/www/html/misc/GeoLite2-City.mmdb
rm -rf /tmp/GeoLite*

echo "GeoIP Done"
