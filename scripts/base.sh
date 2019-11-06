#!/usr/bin/env bash

echo "Setting Timezone & Locale to $3 & en_US.UTF-8"

sudo ln -sf /usr/share/zoneinfo/$3 /etc/localtime
sudo apt-get install -qq language-pack-en
sudo locale-gen en_US
sudo update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8

echo ">>> Installing Base Packages"

if [[ -z $1 ]]; then
    github_url="https://raw.githubusercontent.com/fideloper/Vaprobash/master"
else
    github_url="$1"
fi

# Update
sudo apt-get update

# Install base packages
# -qq implies -y --force-yes
sudo apt-get install -qq curl unzip git-core ack-grep software-properties-common build-essential cachefilesd

HOST=$4

echo ">>> Installing $HOST.xip.io self-signed SSL"

SSL_DIR="/etc/ssl/xip.io"
DOMAIN=".xip.io"
PASSPHRASE="vaprobash"
KEYLINK=$HOST$DOMAIN

SUBJ="
C=US
commonName=$KEYLINK
organizationalUnitName=vagrant
emailAddress=vagrant
"

sudo mkdir -p "$SSL_DIR"

ISINFILE=$(cat /etc/ssl/openssl.cnf | grep -c "subjectAltName=DNS:$KEYLINK,IP:$KEYLINK")
if [[ $ISINFILE -eq 0 ]]; then
    printf "[SAN]\nsubjectAltName=DNS:$KEYLINK,IP:$KEYLINK" | sudo tee -a /etc/ssl/openssl.cnf
fi

# remove random
sudo sed -i '/.rnd/d' /etc/ssl/openssl.cnf

# add key
sudo openssl genrsa -out "$SSL_DIR/$KEYLINK.key" 2048

# add cert
sudo openssl req -new \
-x509 \
-days 365 \
-sha256 \
-subj "$(echo -n "$SUBJ" | tr "\n" "/")" \
-key "$SSL_DIR/$KEYLINK.key" \
-out "$SSL_DIR/$KEYLINK.crt" \
-extensions SAN \
-config /etc/ssl/openssl.cnf \
-passin pass:$PASSPHRASE

# Setting up Swap

# Disable case sensitivity
shopt -s nocasematch

if [[ ! -z $2 && ! $2 =~ false && $2 =~ ^[0-9]*$ ]]; then

    echo ">>> Setting up Swap ($2 MB)"

    # Create the Swap file
    fallocate -l $2M /swapfile

    # Set the correct Swap permissions
    chmod 600 /swapfile

    # Setup Swap space
    mkswap /swapfile

    # Enable Swap space
    swapon /swapfile

    # Make the Swap file permanent
    echo "/swapfile   none    swap    sw    0   0" | tee -a /etc/fstab

    # Add some swap settings:
    # vm.swappiness=10: Means that there wont be a Swap file until memory hits 90% useage
    # vm.vfs_cache_pressure=50: read http://rudd-o.com/linux-and-free-software/tales-from-responsivenessland-why-linux-feels-slow-and-how-to-fix-that
    printf "vm.swappiness=10\nvm.vfs_cache_pressure=50" | tee -a /etc/sysctl.conf && sysctl -p

fi

# Enable case sensitivity
shopt -u nocasematch

# Enable cachefilesd
echo "RUN=yes" > /etc/default/cachefilesd
