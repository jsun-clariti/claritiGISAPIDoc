#!/bin/bash
if [ $# -lt 1 ]
then
    echo Usage: set_default_devhub.sh alias
    exit
fi
sfdx force:config:set defaultdevhubusername=$1