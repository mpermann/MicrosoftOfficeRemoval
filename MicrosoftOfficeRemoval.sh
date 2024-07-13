#!/bin/bash

# Name: MicrosoftOfficeRemoval.sh
# Date: 05-04-2022
# Author: Michael Permann
# Version: 1.0.2
# Modified: 07-13-2024
# Credits: What to remove is based on information from the following Microsoft support document.
# https://support.microsoft.com/en-us/office/uninstall-office-for-mac-eefa1199-5b58-43af-8a3d-b73dc1a8cae3
# Purpose: Remove Microsoft Office 2021 including preferences, receipts and other associatd files from computer.

CURRENT_USER=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')
USER_ID=$(/usr/bin/id -u "$CURRENT_USER")
LOGO="/Library/Management/PCC/Images/PCC1Logo@512px.png"
JAMF_HELPER="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
JAMF_BINARY=$(which jamf)
EDGE="/Applications/Microsoft Edge.app"
REMOTE_DESKTOP="/Applications/Microsoft Remote Desktop.app"
TEAMS="/Applications/Microsoft Teams.app"
SKYPE_BUSINESS="/Applications/Skype for Business.app"

# Remove application bundles
/bin/rm -rf "/Applications/Microsoft Excel.app"
/bin/rm -rf "/Applications/Microsoft OneNote.app"
/bin/rm -rf "/Applications/Microsoft Outlook.app"
/bin/rm -rf "/Applications/Microsoft PowerPoint.app"
/bin/rm -rf "/Applications/Microsoft Word.app"
/bin/rm -rf "/Applications/OneDrive.app"

# Remove LaunchAgents, LaunchDaemons and PrivilegedHelperTools
/bin/rm -rf "/Library/LaunchAgents/com.microsoft.OneDriveStandaloneUpdater.plist"
/bin/rm -rf "/Library/LaunchDaemons/com.microsoft.office.licensingV2.helper.plist"
/bin/rm -rf "/Library/LaunchDaemons/com.microsoft.OneDriveStandaloneUpdaterDaemon.plist"
/bin/rm -rf "/Library/LaunchDaemons/com.microsoft.OneDriveUpdaterDaemon.plist"
/bin/rm -rf "/Library/PrivilegedHelperTools/com.microsoft.office.licensingV2.helper"

# Remove log files
/bin/rm -rf "/Library/Logs/Microsoft/InstallLogs/com.microsoft.package.DFonts.generic.postinstall.log"
/bin/rm -rf "/Library/Logs/Microsoft/InstallLogs/com.microsoft.package.Frameworks.generic.postinstall.log"
/bin/rm -rf "/Library/Logs/Microsoft/InstallLogs/com.microsoft.package.Proofing_Tools.generic.postinstall.log"

# Remove system level preferences
/bin/rm -rf "/Library/Preferences/com.microsoft.office.licensingV2.plist"
/bin/rm -rf "/Library/Preferences/com.microsoft.office.licensingV2.plist.bak"

# Forget package receipts
/usr/sbin/pkgutil --forget "com.microsoft.package.Microsoft_Excel.app"
/usr/sbin/pkgutil --forget "com.microsoft.package.Microsoft_OneNote.app"
/usr/sbin/pkgutil --forget "com.microsoft.package.Microsoft_Outlook.app"
/usr/sbin/pkgutil --forget "com.microsoft.package.Microsoft_PowerPoint.app"
/usr/sbin/pkgutil --forget "com.microsoft.package.Microsoft_Word.app"
/usr/sbin/pkgutil --forget "com.microsoft.OneDrive"
/usr/sbin/pkgutil --forget "com.microsoft.package.DFonts"
/usr/sbin/pkgutil --forget "com.microsoft.package.Frameworks"
/usr/sbin/pkgutil --forget "com.microsoft.package.Proofing_Tools"
/usr/sbin/pkgutil --forget "com.microsoft.pkg.licensing"
/usr/sbin/pkgutil --forget "com.microsoft.pkg.licensing.volume"

# Check if any Microsoft MAU updatable apps remain. If there are, leave MAU on disk for update purposes.
if [[ ! -e "${EDGE}" ]]
then 
    echo "Edge doesn't exist"
    if [[ ! -e ${REMOTE_DESKTOP} ]]
    then
        echo "Remote Desktop doesn't exist"
        if [[ ! -e "${TEAMS}" ]]
        then 
            echo "Teams doesn't exist"
            if [[ ! -e "${SKYPE_BUSINESS}" ]]
            then
                echo "Skype for Business doesn't exist"
                echo "No MAU updatable apps remain so remove MAU"
                /bin/rm -rf "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app"
                /bin/rm -rfd "/Library/Application Support/Microsoft/MAU2.0"
                /bin/rm -rf "/Library/LaunchAgents/com.microsoft.update.agent.plist"
                /bin/rm -rf "/Library/LaunchDaemons/com.microsoft.autoupdate.helper.plist"
                /bin/rm -rf "/Library/PrivilegedHelperTools/com.microsoft.autoupdate.helper"
                /bin/rm -rf "/Library/Logs/Microsoft/autoupdate.log"
                /bin/rm -rf "/Library/Preferences/com.microsoft.autoupdate2.plist"
                /usr/sbin/pkgutil --forget "com.microsoft.package.Microsoft_AutoUpdate.app"
            else
                echo "Skype for Business Exists"
                echo "Leave MAU for update purposes"
            fi
        else
            echo "Teams exists"
            echo "Leave MAU for update purposes"
        fi
    else
        echo "Remote Desktop Exists"
        echo "Leave MAU for update purposes"
    fi
else 
    echo "Edge Exists"
    echo "Leave MAU for update purposes"
fi
