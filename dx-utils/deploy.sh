#!/bin/bash
# use this command to deploy
# traditional metadata to a 
# non-scratch org

###################### THIS IS FOR CIRCLE CI TO FAIL IF THERE IS FAILURE DO NOT REMOVE ######################
# Exit script if a statement returns a non-true return value.
set -o errexit

# Use the error status of the first failure, rather than that of the last item in a pipeline.
set -o pipefail
##############################################################################################################

if [ $# -lt 1 ]
then
    echo 'Usage: deploy.sh alias <checkonly> <deploydir> <waittime>'
    exit
fi



ALIAS=$1
CHECKONLY=$2
DEPLOYDIR=$3
WAITTIME=$4
TESTLEVEL='RunLocalTests'
#SPECIFIED_TESTS='DataTest,DescribeCacheTest,FindTest,LimitsSnapshotTest,QueryTest,SecUtilTest,UserTest'

if [ -z "$CHECKONLY" ]
then
    echo 'real deploy'
else
    echo 'checkonly deploy'
    CHECKONLY='--checkonly'
fi

if [ -z "$DEPLOYDIR"  ]
then
    echo 'default deploy dir'
    DEPLOYDIR='deploy'
else
    echo 'new deploy dir'
fi

if [ -z "$WAITTIME"  ]
then
    echo 'default wait time'
    WAITTIME=45
else
    echo 'new wait time'
fi

sfdx force:mdapi:deploy $CHECKONLY --deploydir $DEPLOYDIR -u $ALIAS --testlevel $TESTLEVEL --ignorewarnings -w $WAITTIME
#sfdx force:mdapi:deploy $CHECKONLY -w -1 --deploydir $DEPLOYDIR -u $ALIAS --testlevel $TESTLEVEL --runtests $SPECIFIED_TESTS -w $WAITTIME
