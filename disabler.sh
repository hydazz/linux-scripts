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
	s) SERVICE="${OPTARG}" ;;
	f) FUNCTION="${OPTARG}" ;;
	?) helpFunction ;;
	esac
done

# print helpFunction in case parameters are empty
if [ -z "${SERVICE}" ] || [ -z "${FUNCTION}" ]; then
	echo -e "${red}>>> ERROR: ${bold}Some or all of the parameters are empty${nc}"
	helpFunction
fi

# ~~~~~~~~~~~~~~~~~~~~~~~
# define loader function
# ~~~~~~~~~~~~~~~~~~~~~~~

function loader() {
	echo -e "${green}>>> ${bold}${FUNCTION}ing ${i}${nc}"
	for i in ${LIST}; do
		launchctl "${FUNCTION}" -w ${i} &>/dev/null
	done

	for i in ${LIST_SUDO}; do
		sudo launchctl "${FUNCTION}" -w ${i} &>/dev/null
	done
	echo ""
}

for i in ${SERVICE}; do

	# ~~~~~~~~~~~~~~~~~~~~~~~
	# validate supplied parameters
	# ~~~~~~~~~~~~~~~~~~~~~~~

	if ! { [ ${i} = "sophos" ] || [ ${i} = "jamf" ] || [ ${i} = "nomad" ]; }; then
		echo -e "${red}>>> ERROR: ${bold}${i} is not a supported service"
		echo -e "Supported services: sophos, jamf and nomad${nc}"
	fi

	# ~~~~~~~~~~~~~~~~~~~~~~~
	# startup
	# ~~~~~~~~~~~~~~~~~~~~~~~

	if [ ${i} = "sophos" ]; then
		LIST=$(find /Library/LaunchAgents -name "*sophos*")
		LIST_SUDO=$(find /Library/LaunchDaemons -name "*sophos*")
		loader
		echo -e "${green}>>> ${bold}Killing all Sophos processes${nc}"
		pgrep "[sS]ophos" | sudo xargs kill
	fi

	if [ ${i} = "jamf" ]; then
		LIST=$(find /Library/LaunchAgents -name "*jamf*")
		LIST_SUDO=$(find /Library/LaunchDaemons -name "*jamf*")
		[[ -f /Library/Application\ Support/JAMF/.jmf_settings.json ]] &&
			sudo rm /Library/Application\ Support/JAMF/.jmf_settings.json
		loader
	fi

	if [ ${i} = "nomad" ]; then
		LIST=$(
			find /Library/LaunchAgents -name "*NoMAD*"
			find /Users/hydea22/Library/LaunchAgents -name "*NoMAD*"
		)
		loader
	fi

done
