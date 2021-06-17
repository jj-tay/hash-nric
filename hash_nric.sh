#!/bin/bash
set -e

# Create tempfile
TEMPFILE=$(mktemp)

# Read input file line by line, standardise NRICs to upper case, detect the 
# unique NRICs in each line, and hash each NRIC by SHA256. Finally, append 
# line to TEMPFILE.
cat $1 |\
sed 's/[a-zA-Z][0-9]\{7\}[a-zA-Z]/\U&/g' |\
while read -r LINE || [ -n "$LINE" ]
    do
        NRICS=$(echo -n $LINE | grep -o '[A-Z][0-9]\{7\}[A-Z]' | sort -u)
        for NRIC in $NRICS
        do
            HASH=$(echo -n $NRIC | sha256sum | awk '{print $1}')
            LINE=$(echo -n $LINE | sed "s/$NRIC/$HASH/g") 
        done
    echo $LINE >> $TEMPFILE 
done

# Move file to location of input file
if [ -z $2 ] 
    then mv $TEMPFILE $(dirname $1)/"hashed_"$1
else
    mv $TEMPFILE $(dirname $1)/$2
fi

