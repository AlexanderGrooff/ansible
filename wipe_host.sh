#!/usr/bin/env bash

set -x

sudo systemctl stop consul
sudo systemctl stop nomad
df -h | grep alloc | awk '{print $6}' | xargs sudo umount
sleep 3
sudo rm -rf /data
