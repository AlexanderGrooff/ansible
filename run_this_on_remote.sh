#!/usr/bin/env bash

set -x
set -e

test "$(whoami)" == 'root' || (echo You\'re not root! && exit 1)

apt-get install sudo -y
grep alex /etc/passwd || useradd alex
echo '%alex ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/0pw4alex
mkdir -p /home/alex/.ssh
cp -ra /root/.ssh/authorized_keys /home/alex/.ssh
chown alex:alex -R /home/alex
chown alex:alex /home/alex
