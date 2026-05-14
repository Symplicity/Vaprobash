#!/usr/bin/env bash

if [[ -z $1 ]]; then
        KIBANA_VERSION="8.19.12"
else
        KIBANA_VERSION=$1
fi

VERBOSE=$2
if [[ $VERBOSE != true ]]; then
    exec >/dev/null 2>&1
fi

echo ">>> Installing Kibana $KIBANA_VERSION"
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-8.x.list
sudo apt-get update && sudo apt-get install -qq kibana=$1

if ! sudo grep -Eq '^[[:space:]]*server\.host:' /etc/kibana/kibana.yml; then
    echo 'server.host: "0.0.0.0"' | sudo tee -a /etc/kibana/kibana.yml
fi

sudo systemctl restart kibana
