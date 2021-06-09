#!/usr/bin/bash

set -e
set -x

grep alex /etc/passwd || sudo useradd alex
echo '%alex ALL=(ALL:ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/0pw4alex
sudo apt-get update
sudo apt-get install -y python3-pip virtualenvwrapper
. /usr/share/virtualenvwrapper/virtualenvwrapper.sh
mkvirtualenv -a . -p python3 $(basename $(pwd))
pip install -r requirements.txt
