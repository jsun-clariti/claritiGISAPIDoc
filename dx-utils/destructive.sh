#!/bin/bash
# use this command to run destructive changes
# from current checked-out branch 

###################### THIS IS FOR CIRCLE CI TO FAIL IF THERE IS FAILURE DO NOT REMOVE ######################
# Exit script if a statement returns a non-true return value.
set -o errexit

# Use the error status of the first failure, rather than that of the last item in a pipeline.
set -o pipefail
##############################################################################################################

if [ $# -lt 1 ]
then
    echo 'Usage: destructive.sh alias [checkonly] [deployDir]'
    exit
fi

ALIAS=$1
CHECKONLY=$2
DEPLOYDIR=$3
WAITTIME=$4

if [ -z "$CHECKONLY" ]
then
    echo 'real destroy'
else
    echo 'checkonly destroy'
    CHECKONLY='--checkonly'
fi

if [ -z "$DEPLOYDIR"  ]
then
    echo 'default destroy dir'
    DEPLOYDIR='destructive'
else
    echo 'new destroy dir'
fi

if [ -z "$WAITTIME"  ]
then
    echo 'default wait time'
    WAITTIME=45
else
    echo 'new wait time'
fi

#validate legacy metadata
# --ignorewarnings is included as warnings are thrown when items in the destructiveChanges.xml do not exist in the org
#                  this happens after the initial run in an environment, and it causes subsequent builds to fail
sfdx force:mdapi:deploy $CHECKONLY --deploydir $DEPLOYDIR -u $ALIAS --ignorewarnings -w $WAITTIME

#sleep 5s

#sfdx force:mdapi:deploy:report