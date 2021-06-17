#!/bin/bash
set -e

LOGFILE=$1
TEMPFILE=$(mktemp)

# Make NRICs upper case
sed -E 's/[a-zA-Z][0-9]{7}[a-zA-Z]/\U&/g' $LOGFILE > $TEMPFILE

# Extract unique NRICs
NRICS=$(grep -Eio '[a-zA-Z][0-9]{7}[a-zA-Z]' $TEMPFILE \
    | sort \
    | uniq)

# Hash each NRIC
for NRIC in $NRICS;
    do
        HASH=$(echo -n $NRIC | md5sum | awk '{print $1}')
        sed -i "s/$NRIC/$HASH/g" $TEMPFILE
    done

# Move file to present directory
mv $TEMPFILE $PWD/"hashed_"$LOGFILE
