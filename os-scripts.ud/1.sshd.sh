#!/bin/bash
export DEBIAN_FRONTEND=noninteractive ;
set -eu ; # abort this script when a command fails or an unset variable is used.
#set -x ; # echo all the executed commands.

apt-get -y install openssh-server ;
echo "UseDNS no" >> /etc/ssh/sshd_config ;
echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config ;
