#!/bin/bash
RED='\033[1;31m'   # echo Red
BLUE='\033[1;34m'  # echo Blue
GREEN='\033[1;32m' # echo Green
BOLD='\033[1;37m'  # echo White Bold
NC='\033[0m'       # echo No Colour
red=$'\e[31m'      # Read Red
nocolor=$'\e[0m'   # Read White
blue=$'\e[34m'     # Read Blue

VIDEO="mp4" # Format to convert videos to
IMAGE="jpg" # Format to convert images to

read -r -p "${blue}Enable Auto-Delete?${nocolor} [Yes/no] " input
case $input in
[yY][eE][sS] | [yY])
	delete="yes"
	;;
[nN][oO] | [nN])
	delete="no"
	;;
*)
	echo "Invalid input..."
	exit 1
	;;
esac

while :; do
	echo -e "${BOLD}Drag File Here${NC}"
	read FILE

	if [[ ! -f "$FILE" ]]; then
		echo -e "${RED}File does not exist${NC}"
		exit 1
	fi

	OLDTYPE="${FILE##*.}"
	NAME="${FILE%%.*}"
	NEWTIME=$(date -r "$FILE" "+%y%m%d%H%M.%S")

	## Detect file type
	if file "$FILE" | grep -qE 'image|bitmap'; then
		ISIMAGE="yes"
	else
		ISIMAGE="no"
	fi

	if file "$FILE" | grep -qE 'Video|Media'; then
		ISVIDEO="yes"
	else
		ISVIDEO="no"
	fi
	##

	## convert files
	if [ "$ISIMAGE" == "yes" ]; then
		echo ""
		echo -e "${BOLD}Image Detected${NC}"
		mv "$FILE" "$NAME"_old."$OLDTYPE"
		set -e
		echo -e "${BLUE}$FILE > $NAME.$IMAGE"
		convert "$NAME"_old."$OLDTYPE" "$NAME.$IMAGE"
		touch -m -t "$NEWTIME" "$NAME.$IMAGE"
		exiftool -TagsFromFile "$NAME"_old."$OLDTYPE" -x Orientation "$NAME.$IMAGE" >/dev/null
		rm "$NAME.$IMAGE"_original
		if [ "$delete" == "yes" ]; then
			rm "$NAME"_old."$OLDTYPE"
		fi
		echo -e "${GREEN}Compete${NC}"
		echo ""
	fi

	if [ "$ISVIDEO" == "yes" ]; then
		echo ""
		echo -e "${BOLD}Video Detected${NC}"
		mv "$FILE" "$NAME"_old."$OLDTYPE"
		read -r -p "${blue}Is This Video Interlaced?${nocolor} [Yes/no] " input
		case $input in
		[yY][eE][sS] | [yY])
			ffmpeg -i "$NAME"_old."$OLDTYPE" -vf yadif -pix_fmt yuv420p "$NAME.$VIDEO"
			;;
		[nN][oO] | [nN])
			ffmpeg -i "$NAME"_old."$OLDTYPE" -pix_fmt yuv420p "$NAME.$VIDEO"
			;;
		*)
			echo "Invalid input..."
			exit 1
			;;
		esac
		touch -m -t "$NEWTIME" "$NAME.$VIDEO"
		exiftool -TagsFromFile "$NAME"_old."$OLDTYPE" -x Orientation "$NAME.$VIDEO" >/dev/null
		rm "$NAME.$VIDEO"_original
		if [ "$delete" == "yes" ]; then
			rm "$NAME"_old."$OLDTYPE"
		fi
		echo -e "${GREEN}Compete${NC}"
	fi

	if [ "$ISVIDEO" == "no" ] && [ "$ISIMAGE" == "no" ]; then
		echo ""
		echo -e "${RED}Invalid File${NC}"
		echo ""
	fi
done
