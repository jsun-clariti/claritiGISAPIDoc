#!/bin/bash
#it will scan for common security review issue patterns

while getopts ":o:" opt; do
    case $opt in
    o)
        OUTPUTDIR=$OPTARG
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        ;;
    esac
done

grep -r -E -n -i -f ./dx-utils/secrev-issues/pattern.txt --include='*.css' --include='*.cmp' --include='*.js' --exclude-dir 'staticresources' --exclude-dir '__tests__' ./force-app > metadataScanIssues.txt

> csmdOutput.txt
COUNT=0;
while read i; do
    patterntxt=$i
    COUNT=$(expr $COUNT + 1)
    while read line; do
    if [[ $line =~ $patterntxt ]] ; then  
    echo -e "\n" $line "\n\t" $(sed "$COUNT!d" ./dx-utils/secrev-issues/displaytext.txt) >> csmdOutput.txt;
    fi
    done < metadataScanIssues.txt
done < ./dx-utils/secrev-issues/pattern.txt
rm metadataScanIssues.txt

if [ -n "$OUTPUTDIR" ]
then
    cp csmdOutput.txt $OUTPUTDIR/
fi
