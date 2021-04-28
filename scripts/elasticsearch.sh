#!/usr/bin/env bash

VERBOSE=$2
if [[ $VERBOSE != true ]]; then
    exec >/dev/null 2>&1
fi

echo ">>> Installing Elasticsearch"

# Set some variables
ELASTICSEARCH_VERSION=$1 # Check https://www.elastic.co/downloads/elasticsearch for latest version

sudo add-apt-repository -y ppa:openjdk-r/ppa
sudo apt-get update
sudo apt-get -y install openjdk-8-jdk openjdk-8-jre
wget --quiet https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELASTICSEARCH_VERSION}-amd64.deb
sudo dpkg -i elasticsearch-${ELASTICSEARCH_VERSION}-amd64.deb
rm elasticsearch-${ELASTICSEARCH_VERSION}-amd64.deb

if ! grep -q "node.master: true" "/etc/elasticsearch/elasticsearch.yml"; then
	sudo echo "node.master: true" >> /etc/elasticsearch/elasticsearch.yml
	sudo echo "node.name: vagrant" >> /etc/elasticsearch/elasticsearch.yml
	sudo echo "cluster.initial_master_nodes: vagrant" >> /etc/elasticsearch/elasticsearch.yml
	sudo echo "discovery.seed_hosts: []" >> /etc/elasticsearch/elasticsearch.yml
	sudo sed -i "s/# index.number_of_shards: 1/index.number_of_shards: 1/" /etc/elasticsearch/elasticsearch.yml
	sudo sed -i "s/# index.number_of_replicas: 0/index.number_of_replicas: 0/" /etc/elasticsearch/elasticsearch.yml
	sudo sed -i "s/# bootstrap.mlockall: true/bootstrap.mlockall: true/" /etc/elasticsearch/elasticsearch.yml
	sudo echo "network.bind_host: 0" >> /etc/elasticsearch/elasticsearch.yml
	sudo echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml
	sudo echo "http.cors.allow-origin: /https?:\/\/localhost(:[0-9]+)?/" >> /etc/elasticsearch/elasticsearch.yml
	sudo echo "action.auto_create_index: ".watches,.triggered_watches,.watcher-history-*"" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
fi 

sudo service elasticsearch restart

sudo update-rc.d elasticsearch defaults 95 10
