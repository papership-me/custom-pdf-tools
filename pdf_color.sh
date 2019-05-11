#!/bin/bash

# https://github.com/papership-me/custom-pdf-tools
#USAGE sh $this.sh file.pdf mode dpi_of_pdf dpi_of_output

FILE="$1"
TMP_FOLDER=_tmp_`hexdump -n 10 -v -e '/1 "%02X"' /dev/urandom`
INPUT_DPI=${3:-600}
OUTPUT_DPI=${4:-400}
RESIZE_PERCENT=$(echo "scale=4;($OUTPUT_DPI/$INPUT_DPI)*100"| bc -l)
NEW_FILENAME=$(echo "${FILE%%.*}")
MODE="$2" # mono gray 3..
BATCH=4

if [ -z "$MODE" ]; then
    MODE="mono"
fi

if [ -f "$FILE" ]
then
	echo "[1] Separating pages of $FILE .."
else
	echo "[ERR] No File: ${FILE}"
	exit
fi

mkdir $TMP_FOLDER
mkdir $TMP_FOLDER/default/
mkdir $TMP_FOLDER/converted/

pdfseparate "$FILE" $TMP_FOLDER/default/%04d.pdf

LAST_PAGE=$(ls "$TMP_FOLDER/default/" | sort -n -r | head -n 1)

#echo "[INF] Color mode: ${MODE}.."

i_iter_count=1
for loc in $TMP_FOLDER/default/*
do 
    fn=$(basename $loc)
    current_pg=$(expr ${fn%%.*})
    progress=$(printf %.2f $(echo "(${fn%%.*}/${LAST_PAGE%%.*})*100"| bc -l))
    
    echo -ne "[2] Working on page ${current_pg}..(${progress}%)\r"
    if [ "${MODE}" == "mono" ]; then
        gm convert -define pdf:use-cropbox=true -density $INPUT_DPI -units PixelsPerInch -limit disk 30gb -limit memory 8gb $TMP_FOLDER/default/$fn -resize ${RESIZE_PERCENT}%x${RESIZE_PERCENT}% -resample $OUTPUT_DPI -colorspace gray -normalize +dither -colors 2 -monochrome -type bilevel -units PixelsPerInch -flatten -compress zip $TMP_FOLDER/converted/$fn &
        NAME_POSTFIX="mono_converted"
    elif [ "${MODE}" == "gray" ]; then
        gm convert -define pdf:use-cropbox=true -density $INPUT_DPI -units PixelsPerInch -limit disk 30gb -limit memory 8gb $TMP_FOLDER/default/$fn -resize ${RESIZE_PERCENT}%x${RESIZE_PERCENT}% -resample $OUTPUT_DPI -colorspace gray -normalize +dither -colors 4 -units PixelsPerInch -flatten -compress zip $TMP_FOLDER/converted/$fn &
        NAME_POSTFIX="gray_converted"
    else
        gm convert -define pdf:use-cropbox=true -density $INPUT_DPI -units PixelsPerInch -limit disk 30gb -limit memory 8gb $TMP_FOLDER/default/$fn -resize ${RESIZE_PERCENT}%x${RESIZE_PERCENT}% -resample $OUTPUT_DPI -normalize +dither -colors $MODE -units PixelsPerInch -flatten -compress zip $TMP_FOLDER/converted/$fn &
        NAME_POSTFIX="${MODE}_color_converted"
    fi
    
    if [ "$i_iter_count" = "$BATCH" ]; then
        i_iter_count=1
        WORK_PID=`jobs -l | awk '{print $2}'`
        wait $WORK_PID
    else
        i_iter_count=$(( $i_iter_count+1 ))
    fi
done

WORK_PID=`jobs -l | awk '{print $2}'`
wait $WORK_PID

echo -ne "\n"

echo "[3] Uniting pages.."

pdfunite $TMP_FOLDER/converted/* "$NEW_FILENAME ${NAME_POSTFIX}.pdf"

echo "[4] Done!"

rm -rf $TMP_FOLDER