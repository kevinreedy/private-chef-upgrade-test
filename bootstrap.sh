#!/bin/bash
set -e

# TODO: support Ubuntu 10.04 and 12.04
# TODO: support RHEL 5 and 6

# Variables
base_version="11.2.2"
upgrade_version="12.3.1"


# Set up
kitchen_data="/tmp/kitchen/data"
tmp_data="/tmp/private-chef-upgrade-test"
mkdir -p $tmp_data

base_install_package="private-chef_$base_version-1_amd64.deb"
base_chef_cmd="/usr/bin/private-chef-ctl"
upgrade_install_package="chef-server-core_$upgrade_version-1_amd64.deb"
upgrade_chef_cmd="/usr/bin/chef-server-ctl"
code_name=$(lsb_release -cs)

# Busser is currently hardcoded to use Chef's ruby, so we need to install Chef
# This may have been fixed in https://github.com/test-kitchen/test-kitchen/pull/833,
# which will be in kitchen 1.4.3
apt-get install -y curl
curl -L https://www.chef.io/chef/install.sh | bash


# If missing, download packages or move packages into place from kitchen data
if [ ! -f $tmp_data/$base_install_package ]
then
  if [ -f $kitchen_data/$code_name/$base_install_package ]
  then
    mv $kitchen_data/$code_name/$base_install_package $tmp_data/
  else
    wget -O "$tmp_data/$base_install_package" "https://packagecloud.io/chef/stable/packages/ubuntu/$code_name/$base_install_package/download"
  fi
fi

if [ ! -f $tmp_data/$upgrade_install_package ]
then
  if [ -f $kitchen_data/$code_name/$upgrade_install_package ]
  then
    mv $kitchen_data/$code_name/$upgrade_install_package $tmp_data/
  else
    wget -O "$tmp_data/$upgrade_install_package" "https://packagecloud.io/chef/stable/packages/ubuntu/$code_name/$upgrade_install_package/download"
  fi
fi


# Install base version of Chef
# TODO: skip if this is already installed
/usr/bin/dpkg -i $tmp_data/$base_install_package
$base_chef_cmd reconfigure


# TODO: knife ec restore


# Upgrade Chef
# TODO: skip if this is already installed
$base_chef_cmd stop
/usr/bin/dpkg -D10 -i $tmp_data/$upgrade_install_package
$upgrade_chef_cmd upgrade
$upgrade_chef_cmd start
$upgrade_chef_cmd cleanup
