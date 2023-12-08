#!/bin/bash
export DEBIAN_FRONTEND=noninteractive ;
set -eu ; # abort this script when a command fails or an unset variable is used.
#set -x ; # echo all the executed commands.

apt-get -yq install sudo ;

# Set up password-less sudo for user vagrant
echo 'vagrant ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vagrant ;
chmod 440 /etc/sudoers.d/vagrant ;

# no tty
echo "Defaults !requiretty" >> /etc/sudoers ;
