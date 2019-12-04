#!/bin/bash

CONVDIR=$1

if [ -d "$CONVDIR" ]; then
    echo "Converting all files in $CONVDIR";
    for i in $CONVDIR/*.wave; do
	name=`echo $i | cut -d'.' -f1`;
	echo $name;
	ffmpeg -i $i -ar 8000 -ac 1 -acodec pcm_mulaw $name.wav
    done
else
    echo "$CONVDIR doesn't appear to be a directory...  Exiting."
    exit 1;
fi
