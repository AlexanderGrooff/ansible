#!/usr/bin/env bash

set -x

HOSTS="theta zeta"

for host in $HOSTS; do
    echo Wiping $host
    ssh $host 'bash -s' < wipe_host.sh
done
