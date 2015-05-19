#!/usr/bin/env bash

echo "Setting Timezone & Locale to $2 & C.UTF-8"

sudo ln -sf /usr/share/zoneinfo/$2 /etc/localtime
sudo locale-gen C.UTF-8
export LANG=C.UTF-8

echo "export LANG=C.UTF-8" >> /home/vagrant/.bashrc

echo ">>> Installing Base Packages"

# Update
sudo apt-get update

# Install base packages
# -qq implies -y --force-yes
sudo apt-get install -qq curl unzip git-core ack-grep software-properties-common build-essential

# Common fixes for git
git config --global http.postBuffer 65536000

# Cache http credentials for one day while pull/push
git config --global credential.helper 'cache --timeout=86400'

# Setting up Swap

# Disable case sensitivity
shopt -s nocasematch

if [[ ! -z $1 && ! $1 =~ false && $1 =~ ^[0-9]*$ ]]; then

    echo ">>> Setting up Swap ($1 MB)"

    # Create the Swap file
    fallocate -l $1M /swapfile

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
