#!/bin/bash
# This script does not remove anything

## Create log file
date '+%d/%m/%Y_%H:%M:%S' >~/."$USER".log
echo "Admin Version" >>~/."$USER".log
echo "Diagnostics Information:" >>~/."$USER".log

clear             # Clear the screen
RED='\033[1;31m'  # echo Red
BLUE='\033[1;34m' # echo Blue
BOLD='\033[1;37m' # echo White Bold
NC='\033[0m'      # echo No Colour
red=$'\e[31m'     # Read Red
nocolor=$'\e[0m'  # Read White
blue=$'\e[34m'    # Read Blue
jamf="jamf"       #
sophos="sophos"   #
familyzone="fz"   #
nomad="nomad"     #
aa="skip"         #
bb="skip"         #
cc="skip"         #
dd="skip"         #

echo -e "${BLUE}You may be asked for your password for elevated privileges${NC}"
echo -e "${BLUE}Press Control+C to cancel at anytime${NC}"

## Create folders...
DIR=/Users/$USER/.installed
if [ ! -d "$DIR" ]; then
	sudo echo "${DIR} Not found... Creating..."
	mkdir "${DIR}"
	touch "${DIR}"/Do\ NOT\ delete\ these\ files!
	touch ~/.installed/sophos
	touch ~/.installed/jamf
	touch ~/.installed/familyzone
	touch ~/.installed/nomad
fi

## Sophos
echo ""
echo "Sophos:" >>~/."$USER".log
DIR=/Applications/Sophos/Sophos\ Endpoint.app
if [ -d "$DIR" ]; then
	FILE=~/.installed/sophos
	if [ -f "$FILE" ]; then
		read -r -p "Am I wanting to ${blue}disable${nocolor} Sophos? [Yes/no] " input
		case $input in
		[yY][eE][sS] | [yY])
			sophos=unload
			echo -e "${RED}Disabling Sophos...${NC}"
			sudo mv /Library/Sophos\ Anti-Virus /Library/_Sophos\ Anti-Virus >>~/."$USER".log 2>&1
			rm ~/.installed/sophos
			aa=noskip
			;;
		[nN][oO] | [nN])
			echo -e "${BLUE}Skipping Sophos${NC}"
			aa=skip
			;;
		*)
			echo "Invalid input..."
			exit 1
			;;
		esac
	else
		read -r -p "Am I wanting to ${red}enable${nocolor} Sophos? [Yes/no] " input
		case $input in
		[yY][eE][sS] | [yY])
			sophos=load
			echo -e "${RED}Enabling Sophos...${NC}"
			sudo mv /Library/_Sophos\ Anti-Virus /Library/Sophos\ Anti-Virus >>~/."$USER".log 2>&1
			touch ~/.installed/sophos
			aa=noskip
			;;
		[nN][oO] | [nN])
			echo -e "${BLUE}Skipping Sophos${NC}"
			aa=skip
			;;
		*)
			echo "Invalid input..."
			exit 1
			;;
		esac
	fi

	if [ "$sophos" == "load" ] || [ "$sophos" == "unload" ]; then
		sudo pkill -f Sophos
		{
			launchctl $sophos -w /Library/LaunchAgents/com.sophos.agent.plist
			launchctl $sophos -w /Library/LaunchAgents/com.sophos.endpoint.uiserver.plist
			sudo launchctl $sophos -w /Library/LaunchDaemons/com.sophos.common.servicemanager.plist
		} >>~/."$USER".log 2>&1
	fi
else
	echo -e "${RED}Sophos is not installed${NC}"
fi

## NoMAD
echo ""
echo "NoMAD:" >>~/."$USER".log
DIR=/Applications/NoMAD.app
if [ -d "$DIR" ]; then
	FILE=~/.installed/nomad
	if [ -f "$FILE" ]; then
		read -r -p "Am I wanting to ${blue}disable${nocolor} NoMAD? [Yes/no] " input
		case $input in
		[yY][eE][sS] | [yY])
			nomad=unload
			echo -e "${RED}Disabling NoMAD...${NC}"
			rm ~/.installed/nomad
			bb=noskip
			;;
		[nN][oO] | [nN])
			echo -e "${BLUE}Skipping NoMAD${NC}"
			bb=skip
			;;
		*)
			echo "Invalid input..."
			exit 1
			;;
		esac
	else
		read -r -p "Am I wanting to ${red}enable${nocolor} NoMAD? [Yes/no] " input
		case $input in
		[yY][eE][sS] | [yY])
			nomad=load
			echo -e "${RED}Enabling NoMAD...${NC}"
			touch ~/.installed/nomad
			bb=noskip
			;;
		[nN][oO] | [nN])
			echo -e "${BLUE}Skipping NoMAD${NC}"
			bb=skip
			;;
		*)
			echo "Invalid input..."
			exit 1
			;;
		esac
	fi
	if [ "$nomad" == "load" ] || [ "$nomad" == "unload" ]; then
		launchctl $nomad -w /Library/LaunchAgents/com.trusourcelabs.NoMAD.plist >>~/."$USER".log 2>&1
		launchctl $nomad -w /Users/hydea22/Library/LaunchAgents/com.trusourcelabs.NoMAD.plist >>~/."$USER".log 2>&1
	fi
else
	echo -e "${RED}NoMAD is not installed${NC}"
fi

## FamilyZone
echo ""
echo "FamilyZone:" >>~/."$USER".log
DIR=/Applications/FamilyZone
if [ -d "$DIR" ]; then
	FILE=~/.installed/familyzone
	if [ -f "$FILE" ]; then
		read -r -p "Am I wanting to ${blue}disable${nocolor} FamilyZone? [Yes/no] " input
		case $input in
		[yY][eE][sS] | [yY])
			familyzone=unload
			echo -e "${RED}Disabling FamilyZone...${NC}"
			rm ~/.installed/familyzone
			cc=noskip
			;;
		[nN][oO] | [nN])
			echo -e "${BLUE}Skipping FamilyZone${NC}"
			cc=skip
			;;
		*)
			echo "Invalid input..."
			exit 1
			;;
		esac
	else
		read -r -p "Am I wanting to ${red}enable${nocolor} FamilyZone? [Yes/no] " input
		case $input in
		[yY][eE][sS] | [yY])
			familyzone=load
			echo -e "${RED}Enabling FamilyZone...${NC}"
			touch ~/.installed/familyzone
			cc=noskip
			;;
		[nN][oO] | [nN])
			echo -e "${BLUE}Skipping FamilyZone${NC}"
			cc=skip
			;;
		*)
			echo "Invalid input..."
			exit 1
			;;
		esac
	fi
	if [ "$familyzone" == "load" ] || [ "$familyzone" == "unload" ]; then
		sudo launchctl $familyzone -w /Library/LaunchDaemons/fz-system-service.plist >>~/."$USER".log 2>&1
		launchctl $familyzone -w /Library/LaunchAgents/com.familyzone.filterclient.agent.plist >>~/."$USER".log 2>&1
		if [ $familyzone == unload ]; then
			ps -ef | grep FamilyZone | grep -v grep | awk '{print $2}' | xargs kill >>~/."$USER".log 2>&1
		fi
	fi
else
	echo -e "${RED}FamilyZone is not installed${NC}"
fi

## JAMF
echo ""
echo "JAMF:" >>~/."$USER".log
DIR=/Library/Application\ Support/JAMF/Jamf.app
if [ -d "$DIR" ]; then
	FILE=~/.installed/jamf
	if [ -f "$FILE" ]; then
		read -r -p "Am I wanting to ${blue}disable${nocolor} JAMF? [Yes/no] " input
		case $input in
		[yY][eE][sS] | [yY])
			jamf=unload
			echo -e "${RED}Disabling JAMF...${NC}"
			rm ~/.installed/jamf
			dd=noskip
			;;
		[nN][oO] | [nN])
			echo -e "${BLUE}Skipping JAMF${NC}"
			dd=skip
			;;
		*)
			echo "Invalid input..."
			exit 1
			;;
		esac
	else
		read -r -p "Am I wanting to ${red}enable${nocolor} JAMF? [Yes/no] " input
		case $input in
		[yY][eE][sS] | [yY])
			jamf=load
			echo -e "${RED}Enabling JAMF...${NC}"
			touch ~/.installed/jamf
			dd=noskip
			FILE=/Library/Application\ Support/JAMF/.jmf_settings.json # Looks for .jmf_settings.json
			if [ -f "$FILE" ]; then                                    # if file exists rename to prevent JAMF blocking terminal
				echo -e "${BLUE}.jmf_settings.json Exists... Deleting to prevent apps being blocked${NC}"
				sudo rm /Library/Application\ Support/JAMF/.jmf_settings.json >>~/."$USER".log 2>&1
			else
				echo -e "${BLUE}.jmf_settings.json Does not exists... Skipping deletion${NC}"
			fi
			;;
		[nN][oO] | [nN])
			echo -e "${BLUE}Skipping JAMF${NC}"
			dd=skip
			;;
		*)
			echo "Invalid input..."
			exit 1
			;;
		esac
	fi
else
	echo -e "${RED}JAMF is not installed${NC}"
fi

if [ $jamf == "load" ] || [ $jamf == "unload" ]; then
	{
		launchctl $jamf -w /Library/LaunchDaemons/com.jamfsoftware.task.1.plist
		launchctl $jamf -w /Library/LaunchDaemons/com.jamfsoftware.jamf.daemon.plist
		launchctl $jamf -w /Library/LaunchDaemons/com.jamf.management.daemon.plist
		launchctl $jamf -w /Library/LaunchAgents/com.jamfsoftware.jamf.agent.plist
	} >>~/."$USER".log 2>&1
fi

if [ $jamf == "load" ]; then
	{
		sudo mv /Library/Application\ Support/JAMF/ManagementFrameworkScripts/loginhook.bak /Library/Application\ Support/JAMF/ManagementFrameworkScripts/loginhook.sh
		sudo mv /Library/Application\ Support/JAMF/ManagementFrameworkScripts/logouthook.bak /Library/Application\ Support/JAMF/ManagementFrameworkScripts/logouthook.sh
		sudo mv /usr/local/jamf/bin/jamfAgent.bak /usr/local/jamf/bin/jamfAgent
		sudo mv /usr/local/jamf/bin/jamf.bak /usr/local/jamf/bin/jamf
	} >>~/."$USER".log 2>&1
fi
if [ $jamf == "unload" ]; then
	{
		sudo mv /Library/Application\ Support/JAMF/ManagementFrameworkScripts/loginhook.sh /Library/Application\ Support/JAMF/ManagementFrameworkScripts/loginhook.bak
		sudo mv /Library/Application\ Support/JAMF/ManagementFrameworkScripts/logouthook.sh /Library/Application\ Support/JAMF/ManagementFrameworkScripts/logouthook.bak
		sudo mv /usr/local/jamf/bin/jamfAgent /usr/local/jamf/bin/jamfAgent.bak
		sudo mv /usr/local/jamf/bin/jamf /usr/local/jamf/bin/jamf.bak
	} >>~/."$USER".log 2>&1
fi

echo ""
if [ "$aa" == "skip" ] && [ "$bb" == "skip" ] && [ "$cc" == "skip" ] && [ "$dd" == "skip" ]; then
	echo -e "${BOLD}No changes were made${NC}"
else
	echo -e "${BOLD}Succsessfully Completed... Have Fun!${NC}"
	read -r -p "${red}Rebooting is recommended after changes, would you like to reboot now? [Yes/no]${nocolor} " input
	case $input in
	[yY][eE][sS] | [yY])
		read -r -p "${blue}Please Save your work and press enter${nocolor} "
		echo -e "${RED}Rebooting...${NC}"
		sudo shutdown -r now
		;;
	[nN][oO] | [nN])
		echo -e "${BLUE}Skipping rebooting${NC}"
		;;
	*)
		echo "Invalid input..."
		exit 1
		;;
	esac
fi

exit 0
