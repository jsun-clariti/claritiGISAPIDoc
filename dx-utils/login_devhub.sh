#!/bin/bash

 
if [ $# -lt 1 ]
then
    HUBALIAS='dev-hub'
else
    HUBALIAS=$1
fi

sfdx auth:web:login --setdefaultdevhubusername -a $HUBALIAS

sfdx force:org:list