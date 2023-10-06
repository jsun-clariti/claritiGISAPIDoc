#!/bin/bash



if [ $# -lt 1 ]
then
    ROOTDIR='src'
else
    ROOTDIR=$1
fi

sfdx force:mdapi:convert --rootdir $ROOTDIR