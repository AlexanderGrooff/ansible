#!/usr/bin/env bash

set -e

# Constants
COOLDOWN_FILE=/tmp/ansible_cooldown.txt
COOLDOWN_DURATION=$((7*24*60*60))

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
    # TODO: Run ansible
    echo "Updating cooldown"
    echo "$DATE_NOW" > $COOLDOWN_FILE
fi
