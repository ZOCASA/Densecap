#!/bin/bash

#Input video filename
FILE_NAME=$(basename $1)
#Directory for images
INPUT_DIR=${1%.*}
#Directory for densecap frame and video output
OUTPUT_DIR=$INPUT_DIR"_out"
IN="-input_dir"
OUT="-output_dir"
FLAG_IN="0"
FLAG_OUT="0"

OPTIONS=""
for VAR in ${@:2}; do
    OPTIONS=$OPTIONS" "$VAR
    #Check if -input_dir and -output_dir
    #already mentioned
    if [ $FLAG_IN -eq 1 ]; then
        FLAG_IN=2
        INPUT_DIR=$VAR
    fi
    if [ "$VAR" == "$IN" ]; then
        FLAG_IN=1
    fi
    if [ $FLAG_OUT -eq 1 ]; then
        FLAG_OUT=2
        OUTPUT_DIR=$VAR
    fi
    if [ "$VAR" == "$OUT" ]; then
        FLAG_OUT=1
    fi
done
#If -input_dir and -output_dir not set
#Set them up
if [ $FLAG_IN -eq 0 ]; then
    if [ ! -d "$INPUT_DIR" ]; then
        if [ -f "$1" ]; then
            mkdir $INPUT_DIR
            #Extract frames from videos
            ffmpeg -i $1 $INPUT_DIR/$filename%06d.jpg
        else
            echo "'$1' not valid. Please check."
            exit 1
        fi
    else
        echo " "
        echo "'$INPUT_DIR' already exist. Using it as input folder."
        echo " "
    fi
fi
if [ $FLAG_OUT -eq 0 ]; then
    if [ ! -d "$OUTPUT_DIR" ]; then
        mkdir $OUTPUT_DIR
    else
        echo " "
        echo "WARNING! '$OUTPUT_DIR' already exist. Using it as output folder."
        echo "This WILL OVERWRITE existing files."
        echo " "
    fi
fi
OPTIONS=$OPTIONS" -input_dir $INPUT_DIR/ -output_dir $OUTPUT_DIR/"
echo " "
echo $OPTIONS
echo " "

#Run the DenseCap model
th run_model.lua $OPTIONS

OLD_WORK_DIR=`pwd`
cd $OUTPUT_DIR
#Contruct a video using the frames
#ONLY FOR JPG IMAGES
ffmpeg -framerate 5 -pattern_type glob -i "*.jpg" -vf "fps=25,format=yuv420p,scale=trunc(iw/2)*2:trunc(ih/2)*2" ${FILE_NAME%.*}".mp4"
cd $OLD_WORK_DIR
