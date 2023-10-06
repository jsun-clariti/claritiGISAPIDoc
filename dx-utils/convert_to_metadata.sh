#!/bin/bash
#convert the dx metadata to traditional 
#metadata format in a ./deploy dir

# bring in config file variables
source config/dx-utils.cfg

if [ $# -lt 1 ]
then
    DEPLOYDIR='deploy'
    ROOTDIR='force-app/main/'
    PACKAGENAME=$DEFAULT_PACKAGE_NAME
else
    DEPLOYDIR=$1
    ROOTDIR=$2
    PACKAGENAME=$3
fi

sfdx force:source:convert -r $ROOTDIR -d $DEPLOYDIR -n "$PACKAGENAME"
cp destructive/destructiveChanges*.xml $DEPLOYDIR

#If you need to assign a post install class assign the DEFAULT_POST_INSTALL_CLASS  and $BRANCHES_FOR_POST_INSTALL_CLASS in dx-utils.cfg
if [[ ! -z $DEFAULT_POST_INSTALL_CLASS ]] && [[ ! -z $BRANCHES_FOR_POST_INSTALL_CLASS ]];
then
    branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
    #Check to see which branch the post install class should be applied to
    for b in $BRANCHES_FOR_POST_INSTALL_CLASS
    do
        if [[ $b == $branch ]];
        then
         node ./dx-utils/assign_post_install_class.js "$DEFAULT_POST_INSTALL_CLASS"
        fi
    done
fi