#!/bin/bash -eu
yum -y install ntp
chkconfig ntpd on
service ntpd start