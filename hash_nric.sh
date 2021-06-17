#!/bin/bash
set -e

# Create tempfile
TEMPFILE=$(mktemp)

# Make NRICs upper case
sed 's/[a-zA-Z][0-9]\{7\}[a-zA-Z]/\U&/g' $1 > $TEMPFILE

# Extract unique NRICs
NRICS=$(grep -o '[A-Z][0-9]\{7\}[A-Z]' $TEMPFILE | sort -u)

# Hash each NRIC
for NRIC in $NRICS
    do
        HASH=$(echo -n $NRIC | sha256sum | awk '{print $1}')
        sed -i "s/$NRIC/$HASH/g" $TEMPFILE
    done

# Move file to location of input file
if [ -z $2 ] 
    then mv $TEMPFILE $(dirname $1)/"hashed_"$1
else
    mv $TEMPFILE $(dirname $1)/$2
fi
