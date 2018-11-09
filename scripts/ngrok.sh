#!/usr/bin/env bash

echo ">>> Installing ngrok"

# check if we have authentication set
if [[ -z $1 ]]; then
    echo ">>> ngrok needs auth token , please create an account in ngrok and get the auth token"
else
    AUTH_TOKEN=$1
    cd /opt
    sudo mkdir ngrok && cd ngrok
    sudo wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
    sudo unzip ngrok-stable-linux-amd64.zip
    sudo chmod +x ngrok
    sudo mv ngrok /usr/local/bin/ngrok
    sudo mkdir /home/vagrant/.ngrok2
    sudo touch /home/vagrant/.ngrok2/ngrok.conf
    sudo echo "web_addr: 0.0.0.0:4040" | sudo tee -a /home/vagrant/.ngrok2/ngrok.conf
    sudo echo "authtoken: $1" | sudo tee -a /home/vagrant/.ngrok2/ngrok.conf

    # Run using
    # ngrok http -config=/home/vagrant/.ngrok2/ngrok.yml 80
fi
