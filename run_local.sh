#!/usr/bin/env bash

PLAYBOOK=${PLAYBOOK:-core.yml}

ansible-playbook $PLAYBOOK -v --connection=local --limit=$(hostname) $@
