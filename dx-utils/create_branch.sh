#!/bin/bash
# use this command when creating a new branch 
# from current checked-out branch
# Default scratch org duration is 15 days (up from 7)

# bring in config file variables
source config/dx-utils.cfg

if [ $# -lt 1 ]
then
    echo Usage: create_branch.sh branchname [duration]
    exit
fi

if [ $# -lt 2 ]
then
    DURATION=$DEFAULT_SCRATCH_ORG_LENGTH
else
    DURATION=$2
fi

#create new branch from current branch
git checkout -b $1;


#push branch to github, starting CI build
git push -u origin $1


# call setup script for org setup
./dx-utils/setup_scratch_org.sh $1 $DURATION;