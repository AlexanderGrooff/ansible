#!/usr/bin/env bash

set -x
set -e

REMOTE=$1

if [ -z "$REMOTE" ]; then
  echo No IP given!
  exit 1
fi

echo Bootstrapping ansible on $REMOTE
scp run_this_on_remote.sh root@$REMOTE:/tmp
ssh root@$REMOTE /tmp/run_this_on_remote.sh
