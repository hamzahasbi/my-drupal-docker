#!/bin/bash

sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 128M/g' /etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 128M/g' /etc/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 2048M/g' /etc/php.ini
sed -i 's/expose_php = On/expose_php = Off/g' /etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php.ini
sed -i 's/;realpath_cache_size = 4096k/realpath_cache_size = 256k/g' /etc/php.ini
sed -i 's/;realpath_cache_ttl = 120/realpath_cache_ttl = 3600/g' /etc/php.ini
sed -i 's/;error_log = syslog/error_log = syslog/g' /etc/php.ini
echo -e 'magic_quotes_gpc = Off\napc.shm_size = 128M\nmagic_quotes_runtime = Off\nregister_globals	= Off' >> /etc/php.ini
echo -e 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> /home/www.vactory8.ma/.bashrc
source /home/www.vactory8.ma/.bashrc
mailcatcher --http-ip=0.0.0.0
# ---------SSL Certificate ------------#
openssl genrsa -des3 -passout pass:x -out /etc/httpd/ssl/apache.pass.key 2048
openssl rsa -passin pass:x -in /etc/httpd/ssl/apache.pass.key -out /etc/httpd/ssl/apache.key
rm /etc/httpd/ssl/apache.pass.key
openssl req -new -key /etc/httpd/ssl/apache.key -out /etc/httpd/ssl/apache.csr \
    -subj "/C=MA/ST=Casablanca/L=Casablanca/O=Void/OU=Ar Department/CN=localhost"
openssl x509 -req -days 365 -in /etc/httpd/ssl/apache.csr -signkey /etc/httpd/ssl/apache.key -out /etc/httpd/ssl/apache.crt

# --------- Database configuration ------------#
VOLUME_MYSQL="/var/lib/mysql"
chown -R mysql:mysql /var/lib/mysql
chmod 755 -R /var/lib/mysql

if [[ ! -d $VOLUME_MYSQL/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_MYSQL"
    echo "=> Installing MySQL ..."

    # Try the 'preferred' solution
    mysqld --initialize-insecure > /dev/null 2>&1

    # IF that didn't work
    if [ $? -ne 0 ]; then
        # Fall back to the 'depreciated' solution
        mysql_install_db > /dev/null 2>&1
    fi

    echo "=> Done!"

else
    echo "=> Using an existing volume of MySQL"
fi

/usr/bin/mysqld_safe > /dev/null 2>&1 &
RET=1
while [ $RET -ne 0 ]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
    if [ $RET -eq 0 ]; then
        mysql -u root <<-EOF
        DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
        DELETE FROM mysql.user WHERE User='';
        DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
        FLUSH PRIVILEGES;
        CREATE USER IF NOT EXISTS 'vactory8_db_user'@'localhost' IDENTIFIED BY 'voidtech';
        CREATE DATABASE IF NOT EXISTS vactory8_db CHARACTER SET utf8 COLLATE utf8_general_ci;
        GRANT ALL PRIVILEGES ON vactory8_db.* TO 'vactory8_db_user'@'localhost' WITH GRANT OPTION;
        FLUSH PRIVILEGES;
EOF
        break
    fi
done
mysqladmin -uroot shutdown
echo "=> Database + user created !"
exec "/usr/bin/supervisord"  > /dev/null 2>&1 &
if [ $? -eq 0 ]; then
    echo "=> Server UP and Running"
else
    echo "=> Something went wrong!!"
fi
exec "/bin/bash"
