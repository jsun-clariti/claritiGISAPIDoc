#!/bin/bash
# use this command to create a scratch
# org based on the current branch
# Default scratch org duration is 15 days (up from 7)

#This script should not need to be changed
#please add custom config to customize_scratch_org.sh

# bring in config file variables
source config/dx-utils.cfg

###################### THIS IS FOR CIRCLE CI TO FAIL IF THERE IS FAILURE DO NOT REMOVE ######################
# Exit script if a statement returns a non-true return value.
set -o errexit

# Use the error status of the first failure, rather than that of the last item in a pipeline.
set -o pipefail
##############################################################################################################

if [ $# -lt 1 ]
then
    echo Usage: setup_scratch_org.sh alias [duration] [do_not_customize]
    exit
fi

if [ $# -lt 2 ]
then
    DURATION=$DEFAULT_SCRATCH_ORG_LENGTH
else
    DURATION=$2
fi

#create a scratch org for this branch
sfdx force:org:create -s -f config/project-scratch-def.json -d $DURATION -a $1;

# Install packages, if needed
for package in $DEFAULT_PACKAGES
do
    echo "Installing Package with ID [$package]"
    sfdx force:package:install -p $package -w 30 -r -u $1
done

## push local code artifacts to scratch org
sfdx force:source:push;

if [ $# -lt 3 ]
then
    #add any custom setup steps to:
    ./dx-utils/customize_scratch_org.sh $1

    # open new scratch org in browser
    if [ -z $DEFAULT_PAGE_OPEN ]
    then
        # Open to setup page
        sfdx force:org:open;
    else
        # Open to specified page
        sfdx force:org:open -p $DEFAULT_PAGE_OPEN
    fi

    exit
fi