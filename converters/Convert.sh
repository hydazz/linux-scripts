#!/bin/bash
echo "1) Interlaced to mp4; 2) Progressive to mp4; 3) Convert to JPEG; 4) Transfer Creation Date"
read option

# Interlaced to mp4
if [ "$option" == "1" ]; then
	while :; do
		set -e
		echo "Drag Interlaced Video Here"
		read FILE
		NAME="${FILE%%.*}"
		EXT=mp4 ## File extention to convert to
		TIME=$(stat -f "%Sm" -t "%y%m%d%H%M.%S" "$FILE")
		VIEWTIME=$(stat -f "%Sm" -t "%m/%d/20%y %H:%M:%S" "$FILE")
		mv "$FILE" "$NAME"_old.$EXT
		ffmpeg-bar -i "$NAME"_old.$EXT -vf yadif -pix_fmt yuv420p "$NAME.$EXT"
		echo "Copying Time: $VIEWTIME to $NAME.$EXT"
		touch -m -t "$TIME" "$NAME.$EXT"
		rm "$NAME"_old.$EXT
	done

fi

#Progressive to mp4
if [ "$option" == "2" ]; then
	while :; do
		set -e
		echo "Drag Video Here"
		read FILE
		NAME="${FILE%%.*}"
		EXT=mp4 ## File extention to convert to
		NEWTIME=$(stat -f "%Sm" -t "%y%m%d%H%M.%S" "$FILE")
		mv "$FILE" "$NAME"_old.$EXT
		ffmpeg-bar -i "$NAME"_old.$EXT -pix_fmt yuv420p "$NAME.$EXT"
		echo "Copying Time: $TIME to $NAME.$EXT"
		touch -m -t "$NEWTIME" "$NAME.$EXT"
		rm "$NAME"_old.$EXT
	done
fi

#Convert to JPEG;
if [ "$option" == "3" ]; then
	#!/bin/bash
	while :; do
		set -e
		echo "Drag Image Here"
		read FILE
		NAME="${FILE%%.*}"
		EXT=jpg ## File extention to convert to
		NEWTIME=$(stat -f "%Sm" -t "%y%m%d%H%M.%S" "$FILE")
		convert "$FILE" "$NAME.$EXT"
		echo "Copying Time: $TIME to $NAME.$EXT"
		touch -m -t "$NEWTIME" "$NAME.$EXT"
		rm "$FILE"
	done

fi

#Transfer creation date
if [ "$option" == "4" ]; then
	#!/bin/bash
	while :; do
		set -e
		echo "Drag Old File Here"
		read FILE
		NEWTIME=$(stat -f "%Sm" -t "%y%m%d%H%M.%S" "$FILE")
		echo "Drag New File Here"
		read NEWFILE
		echo "Copying Time: $NEWTIME to $FILE"
		touch -m -t "$NEWTIME" "$NEWFILE"
		rm "$FILE"
	done
fi
