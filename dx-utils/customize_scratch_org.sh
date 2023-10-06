#!/bin/bash
#use this script to add any custom configuration, data or metadata
#This should not be called as part of circle ci so that tests run correctly
# without permission sets assigned.

# bring in config file variables
source config/dx-utils.cfg

if [ $# -lt 1 ]
then
    echo Usage: customize_scratch_org.sh alias
    exit
fi

echo "Customizing Scratch Org: $1"

# assign any required permission sets
for permset in $DEFAULT_PERMISSION_SETS
do
    echo "Assigning permission set [$permset] to default user"
    sfdx force:user:permset:assign -n $permset
done

#run anonymous apex scripts 
sfdx force:apex:execute -f dx-utils/apex-scripts/get_username.cls -u $1
sfdx force:apex:execute -f ./dx-utils/apex-scripts/dataSetup.apex -u $1

#generate a password for default user
#this is used by puppet 
sfdx force:user:password:generate

#Generate Org details into scratchorgdetails/<orgalias>
./dx-utils/scratch_org_info.sh $1

#create users
for username in $DEFAULT_USERS
do
    echo "Creating user [$username]"
    ./dx-utils/create_user.sh $1 $username
done

#deploy unpackaged folder
sf project deploy start -d ./unpackaged -w 30
#reset tracking after deploying unpackaged
sf project reset tracking -p