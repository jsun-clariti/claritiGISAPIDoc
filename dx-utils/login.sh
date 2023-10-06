#!/bin/bash
# use this command to
# log into org
if [ $# -lt 1 ]
then
    echo 'Usage: login.sh <alias>'
    exit
else
    ALIAS=$1
fi

sfdx auth:web:login -a $ALIAS
sfdx force:org:display -u $ALIAS --verbose