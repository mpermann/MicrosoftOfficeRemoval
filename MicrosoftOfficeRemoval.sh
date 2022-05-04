#!/bin/bash

# Name: MicrosoftOfficeRemoval.sh
# Date: 05-04-2022
# Author: Michael Permann
# Version: 1.0
# Credits: What to remove is based on information from the following Microsoft support document.
# https://support.microsoft.com/en-us/office/uninstall-office-for-mac-eefa1199-5b58-43af-8a3d-b73dc1a8cae3
# Purpose: Remove Microsoft Office 2021 including preferences, receipts and other associatd files from computer.

CURRENT_USER=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')
USER_ID=$(/usr/bin/id -u "$CURRENT_USER")
LOGO="/Library/Application Support/HeartlandAEA11/Images/HeartlandLogo@512px.png"
JAMF_HELPER="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
JAMF_BINARY=$(which jamf)
TITLE="Restart Required"
DESCRIPTION="Your computer needs to restart to complete the removal of Microsoft Office. Your computer will restart immediately after clicking the OK button."
BUTTON1="OK"
DEFAULT_BUTTON="1"
EDGE="/Applications/Microsoft Edge.app"
REMOTE_DESKTOP="/Applications/Microsoft Remote Desktop.app"
TEAMS="/Applications/Microsoft Teams.app"
SKYPE_BUSINESS="/Applications/Skype for Business.app"

# Remove application bundles
/bin/rm -rfv "/Applications/Microsoft Excel.app"
/bin/rm -rfv "/Applications/Microsoft OneNote.app"
/bin/rm -rfv "/Applications/Microsoft Outlook.app"
/bin/rm -rfv "/Applications/Microsoft PowerPoint.app"
/bin/rm -rfv "/Applications/Microsoft Word.app"
/bin/rm -rfv "/Applications/OneDrive.app"

# Remove LaunchAgents, LaunchDaemons and PrivilegedHelperTools
/bin/rm -rfv "/Library/LaunchAgents/com.microsoft.OneDriveStandaloneUpdater.plist"
/bin/rm -rfv "/Library/LaunchDaemons/com.microsoft.office.licensingV2.helper.plist"
/bin/rm -rfv "/Library/LaunchDaemons/com.microsoft.OneDriveStandaloneUpdaterDaemon.plist"
/bin/rm -rfv "/Library/LaunchDaemons/com.microsoft.OneDriveUpdaterDaemon.plist"
/bin/rm -rfv "/Library/PrivilegedHelperTools/com.microsoft.office.licensingV2.helper"

# Remove log files
/bin/rm -rfv "/Library/Logs/Microsoft/InstallLogs/com.microsoft.package.DFonts.generic.postinstall.log"
/bin/rm -rfv "/Library/Logs/Microsoft/InstallLogs/com.microsoft.package.Frameworks.generic.postinstall.log"
/bin/rm -rfv "/Library/Logs/Microsoft/InstallLogs/com.microsoft.package.Proofing_Tools.generic.postinstall.log"

# Remove system level preferences
/bin/rm -rfv "/Library/Preferences/com.microsoft.office.licensingV2.plist"
/bin/rm -rfv "/Library/Preferences/com.microsoft.office.licensingV2.plist.bak"

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
                /bin/rm -rfv "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app"
                /bin/rm -rfdv "/Library/Application Support/Microsoft/MAU2.0"
                /bin/rm -rfv "/Library/LaunchAgents/com.microsoft.update.agent.plist"
                /bin/rm -rfv "/Library/LaunchDaemons/com.microsoft.autoupdate.helper.plist"
                /bin/rm -rfv "/Library/PrivilegedHelperTools/com.microsoft.autoupdate.helper"
                /bin/rm -rfv "/Library/Logs/Microsoft/autoupdate.log"
                /bin/rm -rfv "/Library/Preferences/com.microsoft.autoupdate2.plist"
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

DIALOG=$(/bin/launchctl asuser "$USER_ID" /usr/bin/sudo -u "$CURRENT_USER" "$JAMF_HELPER" -windowType utility -windowPosition lr -title "$TITLE" -description "$DESCRIPTION" -icon "$LOGO" -button1 "$BUTTON1" -defaultButton "$DEFAULT_BUTTON")
if [ "$DIALOG" = "0" ] # Check if the default OK button was clicked
then
    echo "User chose $BUTTON1 so proceeding with install"
    /sbin/shutdown -r now
fi
