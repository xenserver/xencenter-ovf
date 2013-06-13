#!/bin/sh

# Copyright (c) Citrix Systems Inc. 
# All rights reserved.
# 
# Redistribution and use in source and binary forms, 
# with or without modification, are permitted provided 
# that the following conditions are met: 
# 
# *   Redistributions of source code must retain the above 
#     copyright notice, this list of conditions and the 
#     following disclaimer. 
# *   Redistributions in binary form must reproduce the above 
#     copyright notice, this list of conditions and the 
#     following disclaimer in the documentation and/or other 
#     materials provided with the distribution. 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND 
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF 
# SUCH DAMAGE.

# Remove unused packages
# BrianEh, Citrix Labs, Redmond
# Linux Fixup VM

# remove networking
apt-get --purge remove netbase
apt-get --purge remove ifupdown
apt-get --purge remove dhcp3-client
apt-get --purge remove dhcp3-common
apt-get --purge remove iproute
apt-get --purge remove iptables
apt-get --purge remove iputils-ping
apt-get --purge remove net-tools
apt-get --purge remove netcat-traditional
apt-get --purge remove tcpd
apt-get --purge remove traceroute
apt-get --purge remove update-inetd

# remove wget
apt-get --purge remove wget

# remove docs
apt-get --purge remove info
apt-get --purge remove man-db
apt-get --purge remove manpages

# remove other applications
apt-get --purge remove locales
apt-get --purge remove debconf-i18n
apr-get --purge remove ssl
apt-get --purge remove dselect
apt-get --purge remove apt-utils
apt-get --purge remove console-common
apt-get --purge remove console-data
apr-get --purge remove console-tools


# remove any unused dependencies
apt-get autoremove
apt-get clean


# Future Note: executing this last line causes the 
# remainder of the LiveCD build process to fail.
# apt-get remove libusb-0.1-4


