#!/bin/bash
#
# Script to deploy a wrking cobbler installation in Ubuntu Server 14.10
# Author: Luis Henrique Bolson <luis@luisb.net>
#
# Based on http://springerpe.github.io/tech/2014/09/09/Installing-Cobbler-2.6.5-on-Ubuntu-14.04-LTS.html
# 
# Please run as root
#

# Get network information for the given IP
IP_ADDR=$1
NETMASK=$(ifconfig | grep $IP_ADDR | cut -d ':' -f 4)
NETDEVICE=$(ifconfig | grep -B1 $IP_ADDR | head -1 | awk '{print $1}')
NETWORK=$(ipcalc ${IP_ADDR}/${NETMASK} | grep Network | cut -d '/' -f 1 | awk '{print $2}')
NETMASK_HALF=$(expr $(ipcalc ${IP_ADDR}/${NETMASK} | grep Network | cut -d '/' -f 2 | awk '{print $1}') + 1)
DHCP_MIN_HOST=$(ipcalc ${IP_ADDR}/${NETMASK_HALF} | grep Broadcast | awk '{print $2}')
DHCP_MAX_HOST=$(ipcalc ${IP_ADDR}/${NETMASK} | grep HostMax | awk '{print $2}')

# echo $IP_ADDR $NETMASK $NETDEVICE $NETWORK $NETMASK_HALF $DHCP_MIN_HOST $DHCP_MAX_HOST

# Add cobbler repository
wget -qO - http://download.opensuse.org/repositories/home:/libertas-ict:/cobbler26/xUbuntu_14.10/Release.key | apt-key add -
add-apt-repository "deb http://download.opensuse.org/repositories/home:/libertas-ict:/cobbler26/xUbuntu_14.10/ ./"

# Update APT repo and install required packages
apt-get update
apt-get install -y cobbler debmirror isc-dhcp-server libapache2-mod-python

# Move Cobbler Apache config to the right place
cp /etc/apache2/conf.d/cobbler.conf /etc/apache2/conf-available/
cp /etc/apache2/conf.d/cobbler_web.conf /etc/apache2/conf-available/

# Enable the above config
a2enconf cobbler cobbler_web

# Enable Proxy modules
a2enmod proxy
a2enmod proxy_http

# Generate a new django secret key
SECRET_KEY=$(python -c 'import re;from random import choice; import sys; sys.stdout.write(re.escape("".join([choice("abcdefghijklmnopqrstuvwxyz0123456789^&*(-_=+)") for i in range(100)])))')
sed --in-place "s/^SECRET_KEY = .*/SECRET_KEY = '${SECRET_KEY}'/" /usr/share/cobbler/web/settings.py

# Change IP and manage_dhcp in cobbler settings
sed -i "s/127\.0\.0\.1/${IP_ADDR}/" /etc/cobbler/settings
sed -i "s/manage_dhcp: .*/manage_dhcp: 1/" /etc/cobbler/settings

sed -i "s/subnet .* netmask .* {/subnet $NETWORK netmask $NETMASK {/" /etc/cobbler/dhcp.template
sed -i "/option routers             192.168.1.5;/d" /etc/cobbler/dhcp.template
sed -i "/option domain-name-servers 192.168.1.1;/d" /etc/cobbler/dhcp.template
sed -i "s/range dynamic-bootp .*/range dynamic-bootp        ${DHCP_MIN_HOST} ${DHCP_MAX_HOST};/" /etc/cobbler/dhcp.template

sed -i "s/INTERFACES=.*/INTERFACES=\"${NETDEVICE}\"/" /etc/default/isc-dhcp-server

# Get Loaders
cobbler get-loaders

# Permission Workarounds
mkdir /tftpboot
chown www-data /var/lib/cobbler/webui_sessions

# Restart services
service cobblerd restart
cobbler sync






