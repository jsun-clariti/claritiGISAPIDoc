#!/bin/bash
# use this command to finish setting up
# a new scratch org where user_alias 
# is in config/alias-user-def.json

if [ $# -lt 2 ]
then
    echo Usage: new_test_user.sh org_alias user_alias
    exit
fi

#generate a truly unique username is all lowercase and no '+', '-', or '='
USERNAME=$2`openssl rand -base64 7  | sed s/[-+=/]//g | tr [A-Z] [a-z]`@foo.org
#make sure the username 

echo "create $USERNAME"
#create a test user correct user-def.json
sfdx force:user:create -a $2_user --definitionfile ./config/$2-user-def.json username=$USERNAME -u $1
echo "display details for new user $2_user"
#display some details about the new user
sfdx force:user:display -u $USERNAME

#Generate file about user
./dx-utils/scratch_org_info.sh $1 $USERNAME

#display the login url for this user
sfdx force:org:open -r -u $USERNAME
