#!/bin/bash
for pic in *.CR2; do
	echo "Converting $pic to $(basename ${pic%.CR2}.jpg)"
	convert "$pic" -quality 60 "$(basename ${pic%.CR2}.jpg)"
	TIME=$(stat -f "%Sm" -t "%y%m%d%H%M.%S" "$pic")
	exiftool -TagsFromFile "$pic" -x Orientation "$(basename ${pic%.CR2}.jpg)"
	touch -m -t "$TIME" "$(basename ${pic%.CR2}.jpg)"
	rm "$(basename ${pic%.CR2}.jpg)"_original
	rm $pic
done
