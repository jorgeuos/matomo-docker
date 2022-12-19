#!/bin/bash
set -ex

# Ignore schellcheck nag
# shellcheck source=/dev/null
. ./set-envvars.sh

ls -lah "${WORKSPACE_DIR}/custom-files"
cd "${WORKSPACE_DIR}/custom-files" || exit

rm -rf "${TMP_DIR}"
mkdir -p "${TMP_DIR}"

PLUGINS=(
    # Without extension
    custom-zip-file
)

for i in "${PLUGINS[@]}";
do
    unzip "$i.zip" -d "${TMP_DIR}"
done

rsync -avz "${TMP_DIR}"/ "${WORKSPACE_DIR}"/plugins

rm -rf "${TMP_DIR:?}"/*
