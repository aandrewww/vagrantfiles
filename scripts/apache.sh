#!/usr/bin/env bash

HOSTNAME=$2

echo ">>> Installing Apache Server"

if [[ -z $1 ]]; then
    public_folder="/vagrant"
else
    public_folder="$1"
fi

function create_vhost {
cat <<- _EOF_
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName www.$HOSTNAME
    ServerAlias $HOSTNAME
    DocumentRoot $public_folder
    <Directory $public_folder>
        Options Indexes FollowSymLinks Includes ExecCGI
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/$HOSTNAME-error.log
    LogLevel warn
    CustomLog \${APACHE_LOG_DIR}/$HOSTNAME-access.log combined
</VirtualHost>
_EOF_
}

function create_ssl_vhost {
cat <<- _EOF_
<VirtualHost *:443>
    ServerAdmin webmaster@localhost
    ServerName www.$HOSTNAME
    ServerAlias $HOSTNAME
    DocumentRoot $public_folder
    <Directory $public_folder>
        Options Indexes FollowSymLinks Includes ExecCGI
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/error.log

    SSLEngine on
    SSLProxyEngine On
    #### temporary rules #### (delete on production server)
    SSLProxyVerify none
    SSLProxyCheckPeerCN off
    SSLProxyCheckPeerName off
    SSLProxyCheckPeerExpire off
    ##########################
    SSLCertificateFile /etc/apache2/ssl/apache.crt
    SSLCertificateKeyFile /etc/apache2/ssl/apache.key
</VirtualHost>
_EOF_
}

# Add repo for latest FULL stable Apache
# (Required to remove conflicts with PHP PPA due to partial Apache upgrade within it)
sudo add-apt-repository -y ppa:ondrej/apache2

# Update Again
sudo apt-key update
sudo apt-get update

# Install Apache
# -qq implies -y --force-yes
sudo apt-get install -qq apache2

if [ "$3" = true ]; then
    sudo apt-get install openssl
    sudo mkdir /etc/apache2/ssl
cat > /etc/apache2/ssl/openssl.cnf <<EOF
#
# ssl.cnf
#

[ req ]
prompt                  = no
distinguished_name      = server_distinguished_name
req_extensions          = v3_req

[ server_distinguished_name ]
commonName              = $HOSTNAME
stateOrProvinceName     = NC
countryName             = US
emailAddress            = root@$HOSTNAME.com
organizationName        = $HOSTNAME
organizationalUnitName  = $HOSTNAME

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
EOF
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt -config /etc/apache2/ssl/openssl.cnf
    sudo a2enmod rewrite ssl

fi

echo ">>> Configuring Apache"

# Add vagrant user to www-data group
sudo usermod -a -G www-data vagrant

# Apache Config

if [ -f "/etc/apache2/sites-available/$HOSTNAME.conf" ]; then
    echo 'vHost already exists. Aborting'
else
    create_vhost > /etc/apache2/sites-available/${HOSTNAME}.conf

    if [ "$3" = true ]; then
        create_ssl_vhost >> /etc/apache2/sites-available/${HOSTNAME}.conf
    fi

    sudo a2dissite 000-default
    # Enable Site
    cd /etc/apache2/sites-available/ && a2ensite ${HOSTNAME}.conf
    echo -e "\n--- Restarting Apache ---\n"
    sudo service apache2 reload
fi