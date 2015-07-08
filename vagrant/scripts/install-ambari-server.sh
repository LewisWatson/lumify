#!/bin/bash -eu
cp /vagrant/vagrant/config/yum-repos/ambari.repo /etc/yum.repos.d/ambari.repo
yum -y install ambari-server
ambari-server setup --silent
ambari-server restart