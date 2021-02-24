#!/bin/sh
## Wifi network to be blocked
schoolnet=" Woodleigh"
# ^^
date '+%d/%m/%Y %I:%M %p' >/var/log/detect_woodleigh_net.log

## Detect network change
currentnet=$(/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I | awk -F: '/ SSID/{print $2}')
if [ -z "$currentnet" ]; then
	currentnet=" No Wifi"
else
	:
fi
echo "$currentnet" >/Library/Application\ Support/Woodleigh/stats/currentnet.txt
flcurrentnet=$(cat /Library/Application\ Support/Woodleigh/stats/currentnet.txt)
flprevent=$(cat /Library/Application\ Support/Woodleigh/stats/prevnet.txt)
if ! { [ "$flcurrentnet" = "$flprevent" ]; }; then
	echo "Network change detected ($flprevent >$flcurrentnet )" >>/var/log/detect_woodleigh_net.log
else
	echo "No network change detected ($flprevent >$flcurrentnet )" >>/var/log/detect_woodleigh_net.log
	echo "$currentnet" >/Library/Application\ Support/Woodleigh/stats/prevnet.txt
	exit 0
fi
echo "$currentnet" >/Library/Application\ Support/Woodleigh/stats/prevnet.txt
##

## Checks if current SSID = school SSID
if [ "$currentnet" = "$schoolnet" ]; then
	status=load
else
	status=unload
fi
##

## Script to prevent services unloading if already unloaded. occurs when changing from wifi > wifi ! school
currentstat="$status"
echo "$currentstat" >/Library/Application\ Support/Woodleigh/stats/currentstat.txt
flcurrentstat=$(cat /Library/Application\ Support/Woodleigh/stats/currentstat.txt)
flprevstat=$(cat /Library/Application\ Support/Woodleigh/stats/prevstat.txt)
if ! { [ "$flcurrentstat" = "$flprevstat" ]; }; then
	echo "Status change detected ($flprevstat > $flcurrentstat )" >>/var/log/detect_woodleigh_net.log
else
	echo "No status change detected ($flprevstat > $flcurrentstat )" >>/var/log/detect_woodleigh_net.log
	echo "$currentstat" >/Library/Application\ Support/Woodleigh/stats/prevstat.txt
	exit 0
fi
echo "$currentstat" >/Library/Application\ Support/Woodleigh/stats/prevstat.txt
##

echo "$status"ing >>/var/log/detect_woodleigh_net.log

##// Root Script //##
## Sohpos
if [ "$status" = "unload" ]; then
	mv /Library/Sophos\ Anti-Virus /Library/_Sophos\ Anti-Virus >>/var/log/detect_woodleigh_net.log 2>&1
fi

if [ "$status" = "load" ]; then
	mv /Library/_Sophos\ Anti-Virus /Library/Sophos\ Anti-Virus >>/var/log/detect_woodleigh_net.log 2>&1
fi
{
	launchctl $status -w /Library/LaunchDaemons/com.sophos.common.servicemanager.plist
	pkill -f Sophos
} >>/var/log/detect_woodleigh_net.log 2>&1
## End Sophos
## NoMAD
## End NoMAD
## FamilyZone
launchctl $status -w /Library/LaunchDaemons/fz-system-service.plist >>/var/log/detect_woodleigh_net.log 2>&1
ps -ef | grep FamilyZone | grep -v grep | awk '{print $2}' | xargs kill >>/var/log/detect_woodleigh_net.log 2>&1
## End FamilyZone
## JAMF
if [ $status = load ]; then
	{
		sudo mv /Library/Application\ Support/JAMF/ManagementFrameworkScripts/loginhook.bak /Library/Application\ Support/JAMF/ManagementFrameworkScripts/loginhook.sh
		sudo mv /Library/Application\ Support/JAMF/ManagementFrameworkScripts/logouthook.bak /Library/Application\ Support/JAMF/ManagementFrameworkScripts/logouthook.sh
		sudo mv /usr/local/jamf/bin/jamfAgent.bak /usr/local/jamf/bin/jamfAgent
		sudo mv /usr/local/jamf/bin/jamf.bak /usr/local/jamf/bin/jamf
	} >>/var/log/detect_woodleigh_net.log 2>&1
fi
if [ $status = unload ]; then
	{
		sudo mv /Library/Application\ Support/JAMF/ManagementFrameworkScripts/loginhook.sh /Library/Application\ Support/JAMF/ManagementFrameworkScripts/loginhook.bak
		sudo mv /Library/Application\ Support/JAMF/ManagementFrameworkScripts/logouthook.sh /Library/Application\ Support/JAMF/ManagementFrameworkScripts/logouthook.bak
		sudo mv /usr/local/jamf/bin/jamfAgent /usr/local/jamf/bin/jamfAgent.bak
		sudo mv /usr/local/jamf/bin/jamf /usr/local/jamf/bin/jamf.bak
	} >>/var/log/detect_woodleigh_net.log 2>&1
fi
## End JAMF
##// End Root Script //##
##// Non-Root Script //##
echo "" >>/var/log/detect_woodleigh_net.log
echo "##// Non Root Script //##" >>/var/log/detect_woodleigh_net.log
alias launchctl="launchctl asuser 501 launchctl"
## Sophos
{
	launchctl "$status" -w /Library/LaunchAgents/com.sophos.agent.plist
	launchctl "$status" -w /Library/LaunchAgents/com.sophos.endpoint.uiserver.plist
} >>/var/log/detect_woodleigh_net.log 2>&1
## End Sophos

## NoMAD
launchctl "$status" -w /Library/LaunchAgents/com.trusourcelabs.NoMAD.plist >>/var/log/detect_woodleigh_net.log 2>&1
launchctl "$status" -w /Users/hydea22/Library/LaunchAgents/com.trusourcelabs.NoMAD.plist >>/var/log/detect_woodleigh_net.log 2>&1
## End NoMAD

## FamilyZone
launchctl "$status" -w /Library/LaunchAgents/com.familyzone.filterclient.agent.plist >>/var/log/detect_woodleigh_net.log 2>&1
## End FamilyZone

## JAMF
{
	launchctl "$status" -w /Library/LaunchDaemons/com.jamfsoftware.task.1.plist
	launchctl "$status" -w /Library/LaunchDaemons/com.jamfsoftware.jamf.daemon.plist
	launchctl "$status" -w /Library/LaunchDaemons/com.jamf.management.daemon.plist
	launchctl "$status" -w /Library/LaunchAgents/com.jamfsoftware.jamf.agent.plist
} >>/var/log/detect_woodleigh_net.log 2>&1
## End JAMF
echo "##// End Non Root Script //##" >>/var/log/detect_woodleigh_net.log

##// End Non-Root Script //##
exit 0
