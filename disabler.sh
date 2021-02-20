#!/bin/bash

# ~~~~~~~~~~~~~~~~~~~~~~~
# set colours
# ~~~~~~~~~~~~~~~~~~~~~~~

red='\033[1;31m'  # echo Red
bold='\033[1;37m' # echo White Bold
nc='\033[0m'      # echo No Colour

# ~~~~~~~~~~~~~~~~~~~~~~~
# get parameters from user
# ~~~~~~~~~~~~~~~~~~~~~~~

helpFunction() {
	echo ""
	echo -e "${bold}Usage: $0 -s <service> <-l/-u>"
	echo -e "\t-s ervice: Service to load or unload, jamf, sophos, nomad"
	echo -e "\t-l oad: Load the service"
	echo -e "\t-u nload: unload the services${nc}"
	exit 1
}

while getopts "s:lu" opt; do
	case "${opt}" in
	s) SERVICE="${OPTARG}" ;;
	l) FUNCTION="load" ;;
	u) FUNCTION="unload" ;;
	?) helpFunction ;;
	esac
done
# print helpFunction in case parameters are empty
if [ -z "${SERVICE}" ] || [ -z "${FUNCTION}" ]; then
	echo -e "${red}Some or all of the parameters are empty${nc}"
	helpFunction
fi

# ~~~~~~~~~~~~~~~~~~~~~~~
# validate supplied parameters
# ~~~~~~~~~~~~~~~~~~~~~~~

if ! { [ "${SERVICE}" = "sophos" ] || [ "${SERVICE}" = "jamf" ] || [ "${SERVICE}" = "nomad" ]; }; then
	echo -e "${red}Error: ${SERVICE} is not a supported service${nc}"
	echo -e "${bold}Supported services: sophos, jamf and nomad${nc}"
	exit 1
fi

# ~~~~~~~~~~~~~~~~~~~~~~~
# loader function
# ~~~~~~~~~~~~~~~~~~~~~~~

function loader() {
	echo -e "${bold}${FUNCTION}ing ${SERVICE}${nc}"
	for i in ${LIST}; do
		launchctl "${FUNCTION}" -w "${i}" &>/dev/null
	done

	for i in ${LIST_SUDO}; do
		sudo launchctl "${FUNCTION}" -w "${i}" &>/dev/null
	done
}

# ~~~~~~~~~~~~~~~~~~~~~~~
# startup
# ~~~~~~~~~~~~~~~~~~~~~~~

if [ "${SERVICE}" = "sophos" ]; then
	LIST=$(find /Library/LaunchAgents -name "*sophos*")
	LIST_SUDO=$(find /Library/LaunchDaemons -name "*sophos*")
	loader
	echo -e "${bold}Killing all Sophos processes${nc}"
	pgrep "[sS]ophos" | sudo xargs kill
fi

if [ "${SERVICE}" = "jamf" ]; then
	LIST=$(find /Library/LaunchAgents -name "*jamf*")
	LIST_SUDO=$(find /Library/LaunchDaemons -name "*jamf*")
	sudo rm /Library/Application\ Support/JAMF/.jmf_settings.json
	loader
fi

if [ "${SERVICE}" = "nomad" ]; then
	LIST=$(
		find /Library/LaunchAgents -name "*NoMAD*"
		find /Users/hydea22/Library/LaunchAgents -name "*NoMAD*"
	)
	loader
fi
