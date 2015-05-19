sudo echo -e "\n--- Install phpmyadmin ---\n"
sudo echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
sudo echo "phpmyadmin phpmyadmin/app-password-confirm password $1" | debconf-set-selections
sudo echo "phpmyadmin phpmyadmin/mysql/admin-pass password $1" | debconf-set-selections
sudo echo "phpmyadmin phpmyadmin/mysql/app-pass password $1" | debconf-set-selections
sudo echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections

sudo apt-get -y install phpmyadmin

sudo echo -e "\n--- Configure Apache to use phpmyadmin ---\n"
sudo ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
sudo a2enconf phpmyadmin
sudo service apache2 restart
