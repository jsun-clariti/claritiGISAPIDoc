#!/bin/bash

VERSION=6.40.0
SCANDIR=force-app/main/default
OUTPUTDIR=pmd/results
FILENAME=PMD_results.html
RULESET=pmd/pmd_rules.xml

while getopts ":s:o:f:r:" opt; do
  case $opt in
    s)
      SCANDIR=$OPTARG
      ;;
    o)
      OUTPUTDIR=$OPTARG
      ;;
    f)
      FILENAME=$OPTARG
      ;;
    r)
      RULESET=$OPTARG
      ;;
    
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

if [ ! -d "$SCANDIR" ]; then
  echo "Directory $SCANDIR does not exist, not scanning"
  exit
fi

if [ ! -d "$OUTPUTDIR" ]; then
  mkdir -p $OUTPUTDIR
fi

alias pmd="$HOME/pmd-bin-6.40.0/bin/run.sh pmd"
echo "Scanning $SCANDIR folder with $RULESET rules"
echo "output to $OUTPUTDIR/$FILENAME"
$HOME/pmd-bin-6.40.0/bin/run.sh pmd -d $SCANDIR -R $RULESET -f summaryhtml -r $OUTPUTDIR/$FILENAME -failOnViolation false
