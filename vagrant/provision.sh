#!/usr/bin/env bash

HOSTNAME=$1
SERVER_TIMEZONE=$2
PHP_TIMEZONE=$3
MYSQL_ROOT_PASSWORD=$4
DB_NAME=$5
DB_USER=$6
DB_PASS=$7

#######################################
# Apt                                 #
#######################################

echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse' > /tmp/sources
echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse' >> /tmp/sources
echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-backports main restricted universe multiverse' >> /tmp/sources
echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse' >> /tmp/sources

sudo cat /etc/apt/sources.list >> /tmp/sources
sudo cp /tmp/sources /etc/apt/sources.list
sudo rm /tmp/sources

sudo apt-get update --fix-missing
sudo apt-get install -y curl unzip git-core ack-grep software-properties-common build-essential
sudo apt-get install -y python-software-properties lynx libav-tools

#######################################
# Timezone/Locale                     #
#######################################

sudo ln -sf /usr/share/zoneinfo/${SERVER_TIMEZONE} /etc/localtime
sudo locale-gen C.UTF-8
export LANG=C.UTF-8
echo "export LANG=C.UTF-8" >> /home/vagrant/.bashrc

#######################################
# Apache                              #
#######################################

sudo apt-get install -y apache2 apache2-mpm-event

echo "ServerName $HOSTNAME" >> /etc/apache2/apache2.conf
echo "127.0.0.1 $HOSTNAME" >> /etc/hosts

# Setup virtualhost 
VHOST=$(cat <<EOF
<VirtualHost *:80>
	ServerName  $HOSTNAME
	DocumentRoot /vagrant/www/web
	<Directory />
		Options FollowSymLinks
		AllowOverride None
	</Directory>
	<Directory /vagrant/www/web/>
		Options Indexes FollowSymLinks MultiViews
		Require all granted
		AllowOverride All
	</Directory>
    ErrorLog /var/log/${HOSTNAME}_error.log
    LogLevel warn
    CustomLog /${HOSTNAME}_access.log combined
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-enabled/000-default.conf

sudo a2enmod mpm_prefork rewrite headers ssl actions

#######################################
# PHP                                 #
#######################################

sudo apt-get install -y php5-cli php5-mysql php5-curl php5-gd php5-mcrypt php5-memcached php5-intl php5-xdebug php5-apcu libapache2-mod-php5

 # xdebug Config
cat > $(find /etc/php5 -name xdebug.ini) << EOF
zend_extension=$(find /usr/lib/php5 -name xdebug.so)
xdebug.remote_enable = 1
xdebug.remote_connect_back = 1
xdebug.idekey = "vagrant"
xdebug.remote_port = 9000
xdebug.scream=0
xdebug.cli_color=1
xdebug.show_local_vars=1
xdebug.overload_var_dump = 0
EOF

# APCU Config
cat > $(find /etc/php5 -name apcu.ini) << EOF
extension=$(find /usr/lib/php5 -name apcu.so)
apc.rfc1867=on
apc.rfc1867_freq=0
EOF

php5enmod xdebug apcu mcrypt

# alter php.ini settings
for INIFILE in "/etc/php5/apache2/php.ini" "/etc/php5/cli/php.ini"
do
    sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL \& \~E_DEPRECATED \& \~E_STRICT/" $INIFILE
    sudo sed -i "s/display_errors = .*/display_errors = On/" $INIFILE
    sudo sed -i "s/max_input_time = .*/max_input_time = -1/" $INIFILE
    sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 500M/" $INIFILE
    sudo sed -i "s/post_max_size = .*/post_max_size = 500M/" $INIFILE
    sudo sed -i "s/;date.timezone =.*/date.timezone = ${PHP_TIMEZONE/\//\\/}/" $INIFILE
done

sudo service apache2 restart

#######################################
# MySQL                               #
#######################################

sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password ${MYSQL_ROOT_PASSWORD}"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${MYSQL_ROOT_PASSWORD}"

sudo apt-get install -y mysql-server

sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

MYSQL=`which mysql`
Q1="GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;"
Q2="FLUSH PRIVILEGES;"
SQL="${Q1}${Q2}"
$MYSQL -uroot -p$MYSQL_ROOT_PASSWORD -e "$SQL"

service mysql restart

#######################################
# Mail Catcher                        #
#######################################

sudo apt-get install -y libsqlite3-dev ruby1.9.3
gem install --no-rdoc mailcatcher

echo "sendmail_path = /usr/bin/env catchmail -f mail@${HOSTNAME}" | sudo tee /etc/php5/mods-available/mailcatcher.ini

sudo tee /etc/init/mailcatcher.conf <<UPSTART
description "Mailcatcher"

start on runlevel [2345]
stop on runlevel [!2345]

respawn

exec /usr/bin/env $(which mailcatcher) --foreground --http-ip=0.0.0.0
UPSTART

# Start Mailcatcher
sudo service mailcatcher start
sudo php5enmod mailcatcher
sudo service apache2 restart

#######################################
# Initialize database                 #
#######################################

Q1="CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
Q2="CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
Q3="GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO ${DB_USER}@localhost;"
SQL="${Q1}${Q2}${Q3}"

MYSQL=`which mysql`
$MYSQL -uroot -p$MYSQL_ROOT_PASSWORD -e "$SQL"


#######################################
# Composer                            #
#######################################

# Test if Composer is installed
composer -v > /dev/null 2>&1
COMPOSER_IS_INSTALLED=$?

# True, if composer is not installed
if [[ $COMPOSER_IS_INSTALLED -ne 0 ]]; then
    echo ">>> Installing Composer"
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
else
    echo ">>> Updating Composer"
    sudo composer self-update
fi

composer global require "fxp/composer-asset-plugin:1.0.0"

cd /vagrant/www
composer install

cd /vagrant/www/web
echo "<?php require_once 'index-development.php'; " > index.php
