#!/usr/bin/env bash

# Test if PHP is installed
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$?

echo ">>> Installing Nginx"

[[ -z $1 ]] && { echo "!!! IP address not set. Check the Vagrant file."; exit 1; }

if [[ -z $2 ]]; then
    public_folder="/vagrant"
else
    public_folder="$2"
fi

if [[ -z $3 ]]; then
    hostname=""
else
    # There is a space, because this will be suffixed
    hostname=" $3"
fi

# Add repo for latest stable nginx
sudo add-apt-repository -y ppa:nginx/stable

# Update Again
sudo apt-get update

# Install Nginx
# -qq implies -y --force-yes
sudo apt-get install -qq nginx

# Turn off sendfile to be more compatible with Windows, which can't use NFS
sed -i 's/sendfile on;/sendfile off;/' /etc/nginx/nginx.conf

sudo service nginx restart