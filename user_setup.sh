#!/usr/bin/env bash

set -u -o pipefail

# Variables
GROUP='sftp'
ROOT_DIR='/var/sftp'

# Make sure the script is run with root privileges
if [[ "$UID" -ne "0" ]]
then
	echo "Sorry, you are not root."
	exit 1
fi

# Prompt for the username, if the user exists, add him to sftp group
# If he doesn't exist, create it
read -p "Enter the username for the user: " USERNAME
if grep -q "$USERNAME" /etc/passwd; then
    usermod -d "$ROOT_DIR" -s /sbin/nologin -g "$GROUP" "$USERNAME"
else
    useradd -g "$GROUP" -d "$ROOT_DIR" -s /sbin/nologin "$USERNAME" &> /dev/null
    read -p "Enter the password for the user: " PASS
    echo "$PASS" | passwd --stdin "$USERNAME"
fi

exit 0
