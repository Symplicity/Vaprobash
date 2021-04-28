#!/usr/bin/env bash

VERBOSE=$3
if [[ $VERBOSE != true ]]; then
    exec >/dev/null 2>&1
fi

echo ">>> Installing RabbitMQ"

apt-get -y install erlang-nox
wget -O- https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc | sudo apt-key add -
wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo apt-key add -
echo "deb https://dl.bintray.com/rabbitmq-erlang/debian focal erlang-22.x" | sudo tee /etc/apt/sources.list.d/rabbitmq.list
apt-get update
apt-get install -y rabbitmq-server
rabbitmq-plugins enable rabbitmq_management

# Allow guests to login thru rabbitmq management
if ! grep -q "loopback_users" "/etc/rabbitmq/rabbitmq.config"; then
	echo "[{rabbit, [{loopback_users, []}]}]." >> /etc/rabbitmq/rabbitmq.config
fi

service rabbitmq-server restart

rabbitmqctl add_user $1 $2
rabbitmqctl set_permissions -p / $1 ".*" ".*" ".*"
