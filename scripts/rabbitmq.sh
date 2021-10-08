#!/usr/bin/env bash

VERBOSE=$3
if [[ $VERBOSE != true ]]; then
    exec >/dev/null 2>&1
fi

package=rabbitmq-server
RABBITMQ_IS_INSTALLED="$(dpkg-query -W --showformat='${db:Status-Status}' "$package" 2>&1)"
if [ ! $? = 0 ] || [ ! "$RABBITMQ_IS_INSTALLED" = installed ]; then
    echo ">>> Installing RabbitMQ"
    apt-get -y install erlang-nox
    wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo apt-key add -
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
else
    echo ">>> RabbitMQ Server is already installed. Skipping installation"
fi
