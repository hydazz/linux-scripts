#!/bin/bash

while :; do
	set -e
	clear
	echo "Drag Old File Here"
	read FILE
	NEWTIME=$(stat -f "%Sm" -t "%y%m%d%H%M.%S" "$FILE")
	echo "Drag New File Here"
	read NEWFILE
	echo "Copying Time: $NEWTIME to $FILE"
	touch -m -t "$NEWTIME" "$NEWFILE"
	rm "$FILE"
done
