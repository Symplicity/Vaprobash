#!/usr/bin/env bash

VERBOSE=$1
if [[ $VERBOSE != true ]]; then
    exec >/dev/null 2>&1
fi

echo ">>> Installing Supervisord"

# Supervisord
# -qq implies -y --force-yes
sudo apt-get update
sudo apt-get install -qq supervisor
