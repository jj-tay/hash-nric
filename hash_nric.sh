#!/bin/bash
set -e

# Check if infile is defined and existing
if [ -z $1 ]
then
    echo "No input file!"
    exit 1
else
    INFILE_FULLPATH=$(readlink -f $1)
    if [ ! -e $INFILE_FULLPATH ]
    then
        echo $1 not found!
        exit 1
    fi
    INFILE_DIRNAME=$(dirname $INFILE_FULLPATH)
    INFILE_BASENAME=$(basename $INFILE_FULLPATH)
fi

# Create outfile name for use later
if [ -n "$2" ]
then
    OUTFILE_FULLPATH=$(readlink -m $2)
    OUTFILE_DIRNAME=$(dirname $OUTFILE_FULLPATH)
else
    OUTFILE_FULLPATH="$INFILE_DIRNAME/hashed_$INFILE_BASENAME"
    OUTFILE_DIRNAME=$INFILE_DIRNAME
fi

# Create tempfile
TEMPFILE=$(mktemp)

# Read input file line by line, standardise NRICs to upper case, detect the 
# unique NRICs in each line, and hash each NRIC by SHA256. Finally, append 
# line to TEMPFILE.
cat $INFILE_FULLPATH |\
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
if [ ! -d $OUTFILE_DIRNAME ]
then
    mkdir -p $OUTFILE_DIRNAME
fi
mv $TEMPFILE $OUTFILE_FULLPATH
