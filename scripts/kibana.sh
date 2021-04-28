#!/usr/bin/env bash

if [[ -z $1 ]]; then
        KIBANA_VERSION="7.6.0"
else
        KIBANA_VERSION=$1
fi

VERBOSE=$2
if [[ $VERBOSE != true ]]; then
    exec >/dev/null 2>&1
fi

echo ">>> Installing Kibana $KIBANA_VERSION"
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update && sudo apt-get install -qq kibana=$1
sudo systemctl restart kibana
