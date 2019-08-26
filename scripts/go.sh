#!/usr/bin/env bash

# check if a go version is set
if [[ -z $1 ]]; then
        GO_VERSION="latest"
else
        GO_VERSION=$1
fi

# Check if gvm is installed
gvm version > /dev/null 2>&1
GVM_IS_INSTALLED=$?

if [ $GVM_IS_INSTALLED -eq 0 ]; then
    echo "Gvm Already Installed"
else
    # Installing dependencies
    echo "Installing Go version manager"
    sudo apt-get install -qq curl git mercurial make binutils bison build-essential
    bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
    source /home/vagrant/.gvm/scripts/gvm

    if [[ $GO_VERSION -eq "latest" ]]; then
        url="$(wget -qO- https://golang.org/dl/ | grep -oP 'https:\/\/dl\.google\.com\/go\/go([0-9\.]+)\.linux-amd64\.tar\.gz' | head -n 1 )"
        GO_VERSION="$(echo $url | grep -oP 'go[0-9\.]+' | head -c -2 )"
    fi

    echo "Installing Go version "$GO_VERSION
    echo "This will also be the default version"

    gvm install $GO_VERSION --prefer-binary
    gvm use $GO_VERSION --default
fi
