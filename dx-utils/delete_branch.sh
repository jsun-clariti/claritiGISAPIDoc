#!/bin/bash
#use this command when deleting a branch and it's associated scratch org

if [ $# -lt 1 ]
then
    echo Usage: delete_branch.sh branchname
    exit
fi

#run the delete scratch org script
./dx-utils/delete_scratch_org.sh $1

# Fetch the contents of Integration BEFORE switching to it
# Do this so files don't get deleted and recreated and confusing to other processes
git fetch origin integration:integration

# Change to the Integration branch
git checkout integration

#delete the local branch
git branch -D $1;

#delete the remote branch
git push origin --delete $1;

#display current branch name
git branch

