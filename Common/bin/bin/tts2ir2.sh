#!/bin/bash

TMPTTS=tmpTTS;

mkdir $TMPTTS;

echo "Generating Files";
while IFS=, read filename text
do
	echo "Generating $filename";
	say -v Samantha -o $TMPTTS/$filename "$text";
done < $1

echo "Converting Files";
for i in $TMPTTS/*.wave;
  do name=`echo $i | cut -d'.' -f1`;
  echo $name;
  ffmpeg -i $i -acodec pcm_s16le -ar 44100 -ac 2 $name.wav
done

# ffmpeg will generate the new files alongside the originals and won't understand a ".." in the output filename
# Move all generated files to the working (non-temp) directory.
mv $TMPTTS/*.wav ./;

rm -r $TMPTTS;

# Will need to run this on all the output files to convert them to IR2 usable files.
#ffmpeg -i INPUT_FILE.wave -acodec pcm_s16le -ar 44100 OUTPUT_FILE.wav
