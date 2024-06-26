#!/bin/bash

#     Purpose:  Install and configure the ISC-DHCP Server
#        Date:
#      Status: Complete/Done
# Assumptions:
#        Todo:
#  References:
#       Notes: Do not implement the DHCP Server until AFTER you deploy the cluster

# Install the ISC DHCP Server package
sudo apt install -y isc-dhcp-server

sudo cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.orig
curl $REPO/main/Files/etc_dhcp_dhcpd.conf | sudo tee /etc/dhcp/dhcpd.conf
curl $REPO/main/Files/etc_dhcp_dhcpd-hosts.conf | sudo tee /etc/dhcp/dhcpd-hosts.conf
sudo systemctl restart isc-dhcp-server.service
sudo systemctl --no-pages status isc-dhcp-server.service

journalctl -u isc-dhcp-server.service
exit 0

# Follow the log
journalctl -f -u isc-dhcp-server.service
