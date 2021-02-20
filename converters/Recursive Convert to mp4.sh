#!/bin/bash
FILE=$1
VIDEO="mp4" # Format to convert VIDEOs to
OLDTYPE="${FILE##*.}"
NAME="${FILE%%.*}"
NEWTIME=$(date -r "$FILE" "+%y%m%d%H%M.%S")
set -e
echo "Converting $FILE > $NAME.$VIDEO"
mv "$FILE" "$NAME"_old."$OLDTYPE"
ffmpeg-bar -i "$NAME"_old."$OLDTYPE" -pix_fmt yuv420p "$NAME.$VIDEO"
exiftool -TagsFromFile "$NAME"_old."$OLDTYPE" -x Orientation "$NAME.$VIDEO" >/dev/null
touch -m -t "$NEWTIME" "$NAME.$VIDEO"
rm "$NAME"_old."$OLDTYPE"
rm "$NAME.$VIDEO"_original
