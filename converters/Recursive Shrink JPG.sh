#!/bin/bash
FILE=$1
if [ -n "$(find "$FILE" -prune -size +1000000c)" ]; then
	IMAGE="jpg" # Format to convert IMAGEs to
	OLDTYPE="${FILE##*.}"
	NAME="${FILE%%.*}"
	NEWTIME=$(date -r "$FILE" "+%y%m%d%H%M.%S")
	mv "$FILE" "$NAME"_old."$OLDTYPE"
	echo "Shrinking $FILE"
	convert "$NAME"_old."$OLDTYPE" -quality 80 "$NAME.$IMAGE"
	exiftool -TagsFromFile "$NAME"_old."$OLDTYPE" -x Orientation "$NAME.$IMAGE" >/dev/null
	touch -m -t "$NEWTIME" "$NAME.$IMAGE"
	rm "$NAME"_old."$OLDTYPE"
	rm "$NAME.$IMAGE"_original
else
	echo "$FILE is not bigger than 1MB"
fi
