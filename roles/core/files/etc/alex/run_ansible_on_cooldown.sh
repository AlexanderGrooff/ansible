#!/usr/bin/env bash

set -e

# Constants
COOLDOWN_FILE=/etc/alex/ansible_cooldown.txt
COOLDOWN_DURATION=$((7*24*60*60))
ANSIBLE_ROLES_FILE=/etc/alex/ansible_roles.cue

# Parse dates
DATE_NOW=$(date -R)
if [ -f $COOLDOWN_FILE ]; then
    DATE_LAST_RUN=$(date -f $COOLDOWN_FILE -R)
else
    # Initial run. Set to 1970
    DATE_LAST_RUN=$(date --date="@0" -R)
fi

# Check cooldown has expired
if [ $(( $(date -d "$DATE_LAST_RUN" +%s) + $COOLDOWN_DURATION )) -le $(date -d "$DATE_NOW" +%s) ]; then
    echo "Cooldown has expired; running ansible"

    pushd ~/code/ansible
    roles="core $(cue export "$ANSIBLE_ROLES_FILE" | jq -r '.roles[]')"
    for role in $roles; do
        echo "Running $role playbook"
        PLAYBOOK=$role.yml ./run.sh
    done
    popd

    echo "Updating cooldown"
    echo "$DATE_NOW" > $COOLDOWN_FILE
else
    echo "Last ansible run was on $DATE_LAST_RUN"
fi
