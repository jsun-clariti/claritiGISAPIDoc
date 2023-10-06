#!/bin/bash
# use this command to
# log out of hub org

if [ $# -lt 1 ]
then
    echo 'Provide org alias.'
    exit
fi
sfdx auth:logout --targetusername $1 -p
