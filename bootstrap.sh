#!/bin/bash
set -e

# Variables
base_version="11.2.2"
upgrade_version="12.3.1"


# Set up
base_chef_cmd="/usr/bin/private-chef-ctl"
upgrade_chef_cmd="/usr/bin/chef-server-ctl"
kitchen_data="/tmp/kitchen/data"
tmp_data="/tmp/private-chef-upgrade-test"
mkdir -p $tmp_data


# Determine platform and platform version
if uname -a | grep el5
then
  # el5
  code_name="el5"
  base_install_package="private-chef-$base_version-1.$code_name.x86_64.rpm"
  upgrade_install_package="chef-server-core-$upgrade_version-1.$code_name.x86_64.rpm"
  download_prefix="https://packagecloud.io/chef/stable/packages/el/5"
  package_install="/bin/rpm -Uvh --nopostun"
  yum install -y curl
elif uname -a | grep el6
then
  # el6
  code_name="el6"
  base_install_package="private-chef-$base_version-1.$code_name.x86_64.rpm"
  upgrade_install_package="chef-server-core-$upgrade_version-1.$code_name.x86_64.rpm"
  download_prefix="https://packagecloud.io/chef/stable/packages/el/6"
  package_install="/bin/rpm -Uvh --nopostun"
elif uname -a | grep Ubuntu
then
  # ubuntu
  code_name=$(lsb_release -cs)
  base_install_package="private-chef_$base_version-1_amd64.deb"
  upgrade_install_package="chef-server-core_$upgrade_version-1_amd64.deb"
  download_prefix="https://packagecloud.io/chef/stable/packages/ubuntu/$code_name"
  package_install="/usr/bin/dpkg -i -D10"
  apt-get update
  apt-get install -y curl
else
  echo "platform not supported"
  exit 100
fi


# Busser is currently hardcoded to use Chef's ruby, so we need to install Chef
# This may have been fixed in https://github.com/test-kitchen/test-kitchen/pull/833,
# which will be in kitchen 1.4.3
# TODO: skip if this is already installed
curl -L https://www.chef.io/chef/install.sh | bash


# If missing, download packages or move packages into place from kitchen data
if [ ! -f $tmp_data/$base_install_package ]
then
  if [ -f $kitchen_data/$code_name/$base_install_package ]
  then
    mv $kitchen_data/$code_name/$base_install_package $tmp_data/
  else
    wget -O "$tmp_data/$base_install_package" "$download_prefix/$base_install_package/download"
  fi
fi

if [ ! -f $tmp_data/$upgrade_install_package ]
then
  if [ -f $kitchen_data/$code_name/$upgrade_install_package ]
  then
    mv $kitchen_data/$code_name/$upgrade_install_package $tmp_data/
  else
    wget -O "$tmp_data/$upgrade_install_package" "$download_prefix/$upgrade_install_package/download"
  fi
fi


# Install base version of Chef Server
# TODO: skip if this is already installed
$package_install $tmp_data/$base_install_package
$base_chef_cmd reconfigure

echo "hold it right there"
exit 200
# TODO: knife ec restore
/opt/chef/embedded/bin/gem install knife-ec-backup -- --with-pg-config=/opt/opscode/embedded/postgresql/9.2/bin/pg_config



# Upgrade Chef
# TODO: skip if this is already installed
$base_chef_cmd stop
$package_install $tmp_data/$upgrade_install_package
$upgrade_chef_cmd upgrade
$upgrade_chef_cmd start
$upgrade_chef_cmd cleanup
