#!/usr/bin/bash

set -e
set -x

echo "Prepping env for running ansible"
grep alex /etc/passwd || sudo useradd alex
echo '%alex ALL=(ALL:ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/0pw4alex
sudo apt-get update
sudo apt-get install -y python3-pip virtualenvwrapper
. /usr/share/virtualenvwrapper/virtualenvwrapper.sh

echo "Retrieving playbooks"
git clone git@github.com/AlexanderGrooff/ansible.git
pushd ansible

echo "Creating environment"
mkvirtualenv -a . -p python3 $(basename $(pwd))
pip install -r requirements.txt

echo "Applying playbooks"
ansible-playbook core.yml -v -i localhost,

popd
