#!/usr/bin/env bash
sudo apt-get install xbindkeys xautomation

cp .xbindkeysrc ~/.xbindkeysrc
sudo cp xbindkeys.service /etc/systemd/system/xbindkeys.service
pkill xbindkeys && xbindkeys
