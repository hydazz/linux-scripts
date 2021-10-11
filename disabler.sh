#!/bin/bash

# ~~~~~~~~~~~~~~~~~~~~~~~
# set colours
# ~~~~~~~~~~~~~~~~~~~~~~~

red='\033[1;31m'   # red
green='\033[1;32m' # Green
bold='\033[1;37m'  # white bold
nc='\033[0m'       # no colour

# ~~~~~~~~~~~~~~~~~~~~~~~
# get parameters from user
# ~~~~~~~~~~~~~~~~~~~~~~~

helpFunction() {
	echo ""
	echo -e "${bold}Usage: $0 -s <service> -f <load/unload>"
	echo -e "\t-s ervice: Service to load or unload, jamf, sophos, nomad"
	echo -e "\t-f unction: load or unload the services${nc}"
	exit 1
}

while getopts "s:f:" opt; do
	case "${opt}" in
	s) service="${OPTARG}" ;;
	f) function="${OPTARG}" ;;
	?) helpFunction ;;
	esac
done

# print helpFunction in case parameters are empty
if [ -z "${service}" ] || [ -z "${function}" ]; then
	echo -e "${red}>>> ERROR: ${bold}Some or all of the parameters are empty${nc}"
	helpFunction
fi

if [ "${function}" = "load" ]; then
	clfunc="Loading"
elif [ "${function}" = "unload" ]; then
	clfunc="Unloading"
else
	echo -e "${red}>>> ERROR: ${bold}${function} is not a supported function"
	echo -e "Supported functions: load, unload${nc}"
fi

# ~~~~~~~~~~~~~~~~~~~~~~~
# define loader function
# ~~~~~~~~~~~~~~~~~~~~~~~

function loader() {
	echo -e "${green}>>> ${bold}${clfunc} ${clserv}${nc}"
	for i in ${list}; do
		launchctl "${function}" -w "${i}" &>/dev/null
	done

	for i in ${list_sudo}; do
		sudo launchctl "${function}" -w "${i}" &>/dev/null
	done
}

for i in ${service}; do

	# ~~~~~~~~~~~~~~~~~~~~~~~
	# validate supplied parameters
	# ~~~~~~~~~~~~~~~~~~~~~~~

	if ! { [ "${i}" = "sophos" ] || [ "${i}" = "jamf" ] || [ "${i}" = "nomad" ] || [ "${i}" = "familyzone" ]; }; then
		if [ -z "${unknown}" ]; then
			unknown="${i}"
			number="1"
		else
			unknown="${unknown}, ${i}"
			number="((number + 1))"
		fi
	fi

	# ~~~~~~~~~~~~~~~~~~~~~~~
	# startup
	# ~~~~~~~~~~~~~~~~~~~~~~~

	if [ "${i}" = "sophos" ]; then
		clserv="Sophos"
		list=$(find /Library/LaunchAgents -iname "*sophos*")
		list_sudo=$(find /Library/LaunchDaemons -iname "*sophos*")
		if [ -n "${list}" ] || [ -n "${list_sudo}" ]; then
			loader
			if [ "${function}" = "unload" ]; then
				echo -e "${green}>>> ${bold}Killing all Sophos processes${nc}"
				pgrep "[sS]ophos" | sudo xargs kill
			fi
		else
			echo -e "${red}>>> ERROR: ${bold}${clserv} is not installed${nc}"
		fi
	fi

	if [ "${i}" = "jamf" ]; then
		clserv="JAMF"
		list=$(find /Library/LaunchAgents -iname "*jamf*")
		list_sudo=$(find /Library/LaunchDaemons -iname "*jamf*")
		if [ -n "${list}" ] || [ -n "${list_sudo}" ]; then
			[[ -f /Library/Application\ Support/JAMF/.jmf_settings.json ]] &&
				sudo rm /Library/Application\ Support/JAMF/.jmf_settings.json
			loader
		else
			echo -e "${red}>>> ERROR: ${bold}${clserv} is not installed${nc}"
		fi
	fi

	if [ "${i}" = "nomad" ]; then
		clserv="NoMad"
		list=$(
			find /Library/LaunchAgents -iname "*nomad*"
			find /Users/hydea22/Library/LaunchAgents -iname "*nomad*"
		)
		if [ -n "${list}" ] || [ -n "${list_sudo}" ]; then
			loader
		else
			echo -e "${red}>>> ERROR: ${bold}${clserv} is not installed${nc}"
		fi
	fi

	if [ "${i}" = "familyzone" ]; then
		clserv="FamilyZone"
		list=$(
			find /Library/LaunchAgents -iname "*familyzone*"
			find /Library/LaunchAgents -iname "*fz*"
		)
		list_sudo=$(
			find /Library/LaunchDaemons -iname "*familyzone*"
			find /Library/LaunchDaemons -iname "*fz*"
		)
		if [ -n "${list}" ] || [ -n "${list_sudo}" ]; then
			loader
		else
			echo -e "${red}>>> ERROR: ${bold}${clserv} is not installed${nc}"
		fi
	fi
done

if [ "${number}" = "1" ]; then
	echo -e "${red}>>> ERROR: ${bold}${unknown} is not a supported service"
	echo -e "Supported services: sophos, jamf, nomad${nc}"
elif [[ "${number}" -gt "1" ]]; then
	echo -e "${red}>>> ERROR: ${bold}${unknown} are not supported services"
	echo -e "Supported services: sophos, jamf, nomad${nc}"
fi
