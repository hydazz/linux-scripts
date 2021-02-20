#!/bin/bash
for FILE in *.JPG; do
	image="jpg"
	OLDTYPE="${FILE##*.}"
	NAME="${FILE%%.*}"
	NEWTIME=$(stat -f "%Sm" -t "%y%m%d%H%M.%S" "$FILE")
	mv "$FILE" "$NAME"_old."$OLDTYPE"
	set -e
	echo -e "Shrinking $FILE"
	convert "$NAME"_old."$OLDTYPE" -quality 60 "$NAME.jpg"
	exiftool -TagsFromFile "$NAME"_old."$OLDTYPE" -x Orientation "$NAME.jpg"
	touch -m -t "$NEWTIME" "$NAME.jpg"
	rm "$NAME"_old."$OLDTYPE"
	rm "$NAME.jpg_original"
done
