#!/bin/bash
# This script requires a valid Matomo licence key.
# It is ignored by default.

set -ex

# Ignore schellcheck nag
# shellcheck source=/dev/null
. ./set-envvars.sh

echo "Get premium plugins"

rm -rf "${TMP_DIR}"
mkdir -p "${TMP_DIR}"

# Updated list 2022-12-19
PLUGIN_LIST=(
    AbTesting
    ActivityLog
    AdvertisingConversionExport
    Cohorts
    CustomReports
    FormAnalytics
    Funnels
    HeatmapSessionRecording
    LoginSaml
    MediaAnalytics
    MultiChannelConversionAttribution
    RollUpReporting
    SearchEngineKeywordsPerformance
    SEOWebVitals
    UsersFlow
    WhiteLabel
    WooCommerceAnalytics
)

for i in "${PLUGIN_LIST[@]}";
do
    curl -f -sS --data "access_token=${MATOMO_LICENSE}" https://plugins.matomo.org/api/2.0/plugins/"$i"/download/latest?matomo="$MATOMO_VERSION" > "${TMP_DIR}"/"$i".zip
    unzip "${TMP_DIR}/$i.zip" -d "${TMP_DIR}"
done

rsync -avz "${TMP_DIR}"/ "${WORKSPACE_DIR}"/plugins

# clean up
rm -rf "${TMP_DIR}"
