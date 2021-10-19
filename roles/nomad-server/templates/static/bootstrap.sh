#!/usr/bin/bash

set -e

echo "Prepping env for running ansible"
grep alex /etc/passwd || sudo useradd alex
echo '%alex ALL=(ALL:ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/0pw4alex

if [[ $(command -v apt-get) ]]; then
    sudo apt-get update
    sudo apt-get install -y python3-pip virtualenvwrapper
elif [[ $(command -v pacman) ]]; then
    git clone https://aur.archlinux.org/yay.git
    pushd yay
    makepkg -si --noconfirm
    popd
    rm -rf yay

    yay -S --noconfirm python-pip python-virtualenv
fi

echo "Retrieving playbooks"
if [ ! -d ansible ]; then
    git clone https://github.com/AlexanderGrooff/ansible.git
fi
pushd ansible

echo "Creating environment"
if [ -d .venv ]; then
    virtualenv .venv
fi
. .venv/bin/activate
pip install -r requirements.txt
ansible-galaxy collection install -r requirements-ansible-collections.yml
if [ ! -f ansible-password.secret ]; then
    echo "Dummy password so that ansible doesn't complain about missing password" > ansible-password.secret
fi

echo "Applying playbooks"
ansible-playbook core.yml -v -i localhost, --connection=local

popd
