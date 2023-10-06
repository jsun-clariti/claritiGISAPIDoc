#!/bin/bash
# use this command when creating a new branch
# from git hub tag.  This is useful creating a branch from a release tag

if [ $# -lt 2 ]
then
    echo Usage: create_branch_from_tag.sh branch_name tag_name
    exit
fi

#create new branch from tag
git checkout -b $1 $2;


#push branch to github, starting CI build
git push -u origin $1


# call setup script for org setup
./dx-utils/setup_scratch_org.sh $1;
