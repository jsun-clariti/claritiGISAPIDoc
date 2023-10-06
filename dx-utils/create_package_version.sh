#!/bin/bash
#create a package version. Usage: create_package_version.sh PACKAGENAME POSTINSTALLURL TAG

if [ $# -lt 3 ]
then
    echo "Usage: create_package_version.sh PACKAGENAME POSTINSTALLURL TAG"
    exit 1
else
    PACKAGENAME=$1
    POSTINSTALLURL=$2
    TAG=$3
fi

sfdx force:package:version:create --package "$PACKAGENAME" --wait 30 --postinstallurl "$POSTINSTALLURL" -x -c --tag "$TAG"
