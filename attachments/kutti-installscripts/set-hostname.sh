#!/bin/bash -e

if [ "$1" == "" ] ; then
    echo "Usage: $0 NEWHOSTNAME"
    echo
    if [ "$(id -ur)" -ne 0 ]; then
        echo "Note: MUST be run with root privileges"
    fi
    exit 1
fi

if [ "$(id -ur)" -ne 0 ]; then
    echo "$0 can only be run as root. Use sudo."
    exit 1
fi

echo "Setting hostname..."
OLDNAME=$(hostname)
if hostnamectl set-hostname "$1" ; then
    sed --in-place=".bak" "s/${OLDNAME}/$1/g" /etc/hosts
    echo "Hostname changed to $1. Please reboot for changes to reflect."
    exit 0
else
    echo "Hostname not set." >&2
    exit 1
fi
