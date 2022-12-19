#!/bin/bash
set -ex

# This file needs to be included in every script that uses envvars
# Or it will fail, vars are scoped into scripts

< envvars.conf tr ' ' _
while IFS= read -r i;
    # do echo "${i%?}";
do
    # echo "${i}";
    # shellcheck disable=SC2163
    export "$i"
done < envvars.conf

# Just to make sure we have vars
echo "$MATOMO_VERSION"
echo "$MAXMIND_LICENSE_KEY"
echo "$MATOMO_LICENS"
echo "$TMP_DIR"
echo "$WORKSPACE_DIR"
