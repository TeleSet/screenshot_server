#!/usr/bin/bash

# Path generator
UTC=$(date +%s)
#UTC=$(date +%s -d "$dd 1 sec ago")

round10() {
    echo $(( ((${1%.*}+5)/10)*10 ))
}
UTC=$(round10 $UTC)

DIRNAME=${UTC:0:4}'/'${UTC:4:2}'/'${UTC:6:1}'/'
FILENAME="$UTC.jpg"

MINWAIT=0
MAXWAIT=3

FILE="/opt/API/streams.list"
#ROOT_FOLDER="/storage/screenshots"
#ROOT_FOLDER="/home/k2/screenshots"
ROOT_FOLDER="/home/lapsa/screenshots"
THUMB_WIDTH="293"
THUMB_HEIGHT="212"
SERVER='http://fl.tlnt.iptvapi.net:8080'

# stop all ffmpeg
killall -9 ffmpeg > /dev/null 2>&1
killall -9 convert > /dev/null 2>&1

# start worker
declare -a FILEARRAY
FILEARRAY=(`cat "$FILE"`)

for STREAM in "${FILEARRAY[@]}"
do
	#echo $STREAM
	FILENAME_ROOT="$ROOT_FOLDER/$STREAM.jpg"
	FILENAME_THUMB=$ROOT_FOLDER"/"$STREAM"_thumb.jpg"
	FULL_PATCH="$ROOT_FOLDER/$STREAM/$DIRNAME"
	URL="$SERVER/$STREAM/preview.mp4"

	CMD1="sleep $((MINWAIT+RANDOM % (MAXWAIT-MINWAIT))) && mkdir -p $FULL_PATCH"
	CMD2="(ffmpeg -loglevel error -y -timeout 5000000 -i $URL -qscale:v 10 -an -frames:v 1 -f image2 -huffman optimal $FULL_PATCH$FILENAME -abort_on empty_output  > /dev/null 2>&1 || cp -f /opt/API/default.jpg $FILENAME_ROOT > /dev/null 2>&1)"
	THUMB=$THUMB_WIDTH"x"$THUMB_HEIGHT
	CMD3="cp -f $FULL_PATCH$FILENAME $FILENAME_ROOT && convert -thumbnail $THUMB^ -gravity center -extent $THUMB $FILENAME_ROOT $FILENAME_THUMB"
	#CMD3_ALT="cp -f /opt/API/default.jpg $FILENAME_ROOT && cp -f /opt/API/default_thumb.jpg $FILENAME_THUMB"
	#echo $CMD3

	CMD=$CMD1" && "$CMD2" && "$CMD3" &"
	#echo $CMD
	#echo $STREAM
	#echo $URL
	#echo $FULL_PATCH
	#echo $CMD1
	echo $CMD2
	#echo $CMD3
	
	#eval $CMD1
	#eval $CMD2
	#eval $CMD3
	eval $CMD
	#printf '\n'

done

# get preview
##curl -u api:yL8bXCf3eymvLN_new http://fl.tlnt.iptvapi.net:8080/$STREAM/preview.mp4 -o $STREAM.mp4
#ffmpeg -loglevel error -y -timeout 5000000 -i $URL -qscale:v 10 -an -frames:v 1 -f image2 -huffman optimal $FILENAME -abort_on empty_output
#convert -thumbnail $THUMB_WIDTHx$THUMB_HEIGHT^ -gravity center -extent $THUMB_WIDTHx$THUMB_HEIGHT "$FILENAME" "$FILENAME_THUMB"

