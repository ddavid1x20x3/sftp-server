#!/usr/bin/env bash

set -e -u -o pipefail

# Variables
GROUP='sftp'
PUBLIC_DIR='/var/sftp/pub'

function c() {

    clear

}

c

# Make sure the script is run with root privileges
if [[ "$UID" -ne "0" ]]
then
	echo "Sorry, you are not root."
	exit 1
fi

# Make sure SSH service is active
if systemctl is-active sshd | grep -q 'failed'; then
    echo 'Ensure SSH server is configured and active before running this script.'
    exit 1
fi

# Install FTP client if not already installed
if ! rpm -qa | grep -q '^ftp'; then
    echo 'Installing FTP client...'
    dnf install -y ftp
    c
fi

# Check if SFTP group already exists, and create it if it doesn't
grep -q "$GROUP" /etc/group || groupadd "$GROUP"

# Create SFTP directory tree
mkdir -p "$PUBLIC_DIR"

# Modify the ownership and permissions of sftp directory
chown :sftp "$PUBLIC_DIR"
chmod 770 "$PUBLIC_DIR"

# Change default SFTP subsystem on RHEL
sed -i 's#/usr/libexec/openssh/sftp-server#internal-sftp#' /etc/ssh/sshd_config

cat <<-"EOF" >> /etc/ssh/sshd_config
Match Group sftp
	ChrootDirectory /var/sftp
EOF

systemctl restart sshd

exit 0