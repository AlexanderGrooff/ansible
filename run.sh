#!/usr/bin/env bash

# Run like './run.sh' or './run.sh alpha'

PLAYBOOK=${PLAYBOOK:-core.yml}
TARGETS=$1

function activate_venv {
    if [ -z $VIRTUAL_ENV ]; then
        local DIR_NAME=$(basename $(pwd))
        if [ -d ~/.virtualenvs/$DIR_NAME ]; then
            source ~/.virtualenvs/$DIR_NAME/bin/activate
        elif [ -d .venv ]; then
            source .venv/bin/activate
        fi
    fi
}

activate_venv
if [ -z $TARGETS ]; then
    ansible-playbook $PLAYBOOK -v --connection=local --limit=$(hostnamectl hostname || hostname)
else
    ansible-playbook $PLAYBOOK -v --limit=$TARGETS
fi
