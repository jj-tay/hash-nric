#!/bin/bash
set -e

INFILE=$1

# Check if infile is defined and existing
if [ -z $INFILE ]
then
    echo "No input file!"
    exit 1
else
    if [ ! -e $INFILE ]
    then
        echo $INFILE not found!
        exit 1
    fi
fi

# Create outfile name for use later
if [ -n "$2" ]
then
    OUTFILE=$2
else
    OUTFILE=$(dirname $INFILE)/hashed_$INFILE
fi
OUTFILE_DIRNAME=$(dirname $OUTFILE)

# Create tempfile
TEMPFILE=$(mktemp)

# Read input file line by line, standardise NRICs to upper case, detect the
# unique NRICs in each line, and hash each NRIC by SHA256. Finally, append
# line to TEMPFILE.
cat $INFILE |\
sed 's/[a-zA-Z][0-9]\{7\}[a-zA-Z]/\U&/g' |\
while read -r LINE || [ -n '$LINE' ]
do
    NRICS=$(echo -n $LINE | grep -o '[A-Z][0-9]\{7\}[A-Z]' | sort -u)
    for NRIC in $NRICS
    do
        HASH=$(echo -n $NRIC | sha256sum | awk '{print $1}')
        LINE=$(echo -n $LINE | sed 's/$NRIC/$HASH/g')
    done
    echo $LINE >> $TEMPFILE
done

# Move file to location of input file
if [ ! -d $OUTFILE_DIRNAME ]
then
    mkdir -p $OUTFILE_DIRNAME
fi
mv $TEMPFILE $OUTFILE
