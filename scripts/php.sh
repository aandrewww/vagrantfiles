#!/usr/bin/env bash

export LANG=C.UTF-8

PHP_TIMEZONE=$1
PHP_VERSION=$2

	echo ">>> Installing PHP $PHP_VERSION"

	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
	
	if [ $PHP_VERSION == "5.5" ]; then
		# Add repo for PHP 5.5
		sudo add-apt-repository -y ppa:ondrej/php5
	else
		# Add repo for PHP 5.6
		sudo add-apt-repository -y ppa:ondrej/php5-5.6
	fi

	sudo apt-key update
	sudo apt-get update

	# Install PHP
	# -qq implies -y --force-yes
	echo -e "\n--- Installing PHP ---\n"
	sudo apt-get -y install php5 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt php5-mysql php-apc



	# PHP Error Reporting Config
	sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/" /etc/php5/apache2/php.ini
	sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini

	# PHP Date Timezone
	sudo sed -i "s/;date.timezone =.*/date.timezone = ${PHP_TIMEZONE/\//\\/}/" /etc/php5/apache2/php.ini
	sudo sed -i "s/;date.timezone =.*/date.timezone = ${PHP_TIMEZONE/\//\\/}/" /etc/php5/apache2/php.ini

	# Turn off disabled pcntl functions so we can use Boris
	sed -i "s/disable_functions = .*//" /etc/php5/cli/php.ini

	sudo service apache2 restart
