#!/bin/bash

TMPTTS=tmpTTS;

mkdir $TMPTTS;


# Feed a CSV, first column filename, 2nd column text
echo "Generating Files";
IFS=','
while read filename text
do
	echo "Generating $filename";
	say -v Samantha -o $TMPTTS/$filename "$text";
done < $1

echo "Converting Files";
for i in $TMPTTS/*.wave;
  do name=`echo $i | cut -d'.' -f1`;
  echo $name;
  ffmpeg -i $i -ar 8000 -ac 1 -acodec pcm_mulaw $name.wav
done

# ffmpeg will generate the new files alongside the originals and won't understand a ".." in the output filename
# Move all generated files to the working (non-temp) directory.
mv $TMPTTS/*.wav ./;

rm -r $TMPTTS;

