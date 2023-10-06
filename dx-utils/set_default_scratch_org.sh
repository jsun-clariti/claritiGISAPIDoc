#!/bin/bash
if [ $# -lt 1 ]
then
    echo Usage: set_default_scratch_org.sh alias
    exit
fi
sfdx force:config:set defaultusername=$1