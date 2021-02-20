#!/bin/bash
for pic in *.tiff; do
	echo "Converting $pic to $(basename ${pic%.tiff}.jpg)"
	convert "$pic" "$(basename ${pic%.tiff}.jpg)"
	TIME=$(stat -f "%Sm" -t "%y%m%d%H%M.%S" "$pic")
	exiftool -TagsFromFile "$pic" -x Orientation "$(basename ${pic%.tiff}.jpg)"
	touch -m -t "$TIME" "$(basename ${pic%.tiff}.jpg)"
	rm "$pic"
done
