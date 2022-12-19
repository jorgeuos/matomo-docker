#!/bin/bash
set -xe

# Ignore schellcheck nag
# shellcheck source=/dev/null
. ./set-envvars.sh

echo "Get contrib plugins"

rm -rf "${TMP_DIR}"
mkdir -p "${TMP_DIR}"

# Contrib Plugins
plugins=(
    CustomOptOut
    GroupPermissions
    InvalidateReports
    AdminNotification
    UserConsole
    QueuedTracking
    TrackerDomain
    GoogleAnalyticsImporter
    BotTracker
    DevelopmentToogle
    MarketingCampaignsReporting
)
for i in "${plugins[@]}"
do
  curl -f -sS https://plugins.matomo.org/api/2.0/plugins/"$i"/download/latest?matomo="$MATOMO_VERSION" > "${TMP_DIR}"/"$i".zip
  unzip "${TMP_DIR}/$i.zip" -d "${TMP_DIR}"
done

# Make sure the dir exist before it is mounted
mkdir -p "${WORKSPACE_DIR}/plugins"
rsync -avz "${TMP_DIR}"/ "${WORKSPACE_DIR}/plugins"

# clean up
rm -rf "${TMP_DIR:?}"/*
