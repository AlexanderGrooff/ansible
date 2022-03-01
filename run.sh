#!/usr/bin/env bash

# Run like './run.sh' or './run.sh alpha'

PLAYBOOK=${PLAYBOOK:-core.yml}
TARGETS=$1

if [ -z $TARGETS ]; then
    ansible-playbook $PLAYBOOK -v --connection=local --limit=$(hostname)
else
    ansible-playbook $PLAYBOOK -v --limit=$TARGETS
fi
