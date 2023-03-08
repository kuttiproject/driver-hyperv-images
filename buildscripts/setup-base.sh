#!/bin/sh -eu

if [ "$(id -ur)" -ne "0" ]; then
    echo "$0 can only be run as root. Use sudo."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# Update GRUB settings
echo "==> Updating GRUB settings"

## Set boot loader timeout to 0
echo "Seting boot loader timeout"
sed -i 's/GRUB_TIMEOUT=\(.*\)/GRUB_TIMEOUT=0/g' /etc/default/grub;
echo "Done."

## Update grub
echo "Updating GRUB..."
update-grub;
echo "Done."

# Add/edit directories and files

echo "==> Adding/editing directories and files..."

## Patch networking
## Adding a 2 sec delay to the interface up, to make the dhclient happy
echo "pre-up sleep 2" >> /etc/network/interfaces

## Set up directory for later copying of kutti interface scripts
mkdir -p /home/kuttiadmin/kutti-installscripts
chown kuttiadmin:kuttiadmin /home/kuttiadmin/kutti-installscripts

## Set up basic motd
echo "Welcome to kutti." > /etc/motd

# Add required system packages
echo "==> Adding required system packages"

echo "Installing bash completion, vim and curl..."
apt-get install -y apt-transport-https bash-completion vim curl gnupg
echo "Done."

# Add user1
echo "==> Adding user1"
adduser --gecos "User 1" --disabled-password user1
chpasswd <<EOPASSWD
user1:Pass@word1
EOPASSWD
adduser user1 sudo

# Add a long DHCP lease
echo "# Long lease added by kutti setup" >> /etc/dhcp/dhclient.conf
echo "send dhcp-lease-time 604800;" >> /etc/dhcp/dhclient.conf
