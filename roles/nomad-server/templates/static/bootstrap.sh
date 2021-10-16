#!/usr/bin/bash

set -e
set -x

test "$(whoami)" == 'root' || (echo "You're not root!" && exit 1)

echo "Prepping env for running ansible"
grep alex /etc/passwd || sudo useradd alex
echo '%alex ALL=(ALL:ALL) NOPASSWD:ALL' | tee /etc/sudoers.d/0pw4alex
apt-get update
apt-get install -y python3-pip virtualenvwrapper git
. /usr/share/virtualenvwrapper/virtualenvwrapper.sh

echo "Retrieving playbooks"
git clone git@github.com/AlexanderGrooff/ansible.git
cd ansible

echo "Creating environment"
mkvirtualenv -a . -p python3 $(basename $(pwd))
pip install -r requirements.txt
