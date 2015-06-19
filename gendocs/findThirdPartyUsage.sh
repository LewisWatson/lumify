#!/bin/bash
###############################################################################
## Basic script to find where the usage of major third party dependencies
## extends to
## John McParland
## F 19 June 2015
###############################################################################

# Dependencies to look for - get them from the command line if specified
DEPENDENCIES=(hadoop accumulo securegraph owlapi)
if [[ 0 -ne ${#} ]];then
    DEPENDENCIES=( "$@" ) 
fi

# Go into the source
cd ..

# Loop round each dependnecy and store the results in a file
for DEP in "${DEPENDENCIES[@]}";do
    OUTFILE=gendocs/${DEP}_usage.txt
    echo "Use of ${DEP}" > ${OUTFILE}
    echo "=====================================================================" >> ${OUTFILE}
    find . -name '*.java' -exec grep -i ${DEP} /dev/null {} \; | cut -f1 -d: | cut -f1-3 -d"/" | sort | uniq >> ${OUTFILE}
done

# Go back to where we were
cd - >> /dev/null

