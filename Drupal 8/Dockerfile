FROM centos:latest
MAINTAINER Hasbi Hamza <h.hasbi@void.fr>
# ---------Image Arguments------------#
ARG project_home=www.vactory8.ma
ARG project_name=vactory8
ARG database_name=vactory8_db
ARG database_user=vactory8_db_user
ARG database_user_psswd=voidtech


# --------- Basic Utilities + Apache ------------#
RUN yum -y install vim nano
RUN yum -y update; yum clean all
RUN yum -y install iproute hostname inotify-tools yum-utils which \
python-setuptools httpd \
&& mkdir -p /var/log/supervisor \
&& easy_install supervisor && yum clean all

# --------- MariaDb + php ------------#
COPY Scripts/MariaDB.repo /etc/yum.repos.d/MariaDB.repo
RUN yum clean all && yum -y install mariadb-server mariadb-client \
epel-release && rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm
RUN yum -y install mod_ssl openssl && yum -y update \
&& yum-config-manager -y --enable remi-php72
RUN yum -y install php php-opcache php-mysqlnd php-pdo php-gd php-ldap php-odbc php-pear php-xml \
php-xmlrpc php-mbstring php-soap curl curl-devel php-xdebug php-intl \
memcached php-pecl-memcache php-pecl-memcached php-pecl-imagick php-pecl-apcu \
&& chkconfig memcached on

# --------- Server Config ------------#
RUN mkdir /var/www/html/${project_home}/ && mkdir /var/www/html/${project_home}/public_html && mkdir /etc/httpd/ssl \
&& chmod 770 -R /var/log/httpd \
&& mkdir -p /home/${project_home}/shared/sites/default/files \
&& mkdir /home/${project_home}/public_html
COPY Scripts/01_project.conf /etc/httpd/conf.d/01_project.conf
RUN yum install -y phpMyAdmin \
&& sed -i 's/Require ip 127.0.0.1//g' /etc/httpd/conf.d/phpMyAdmin.conf \
&& sed -i 's/Require ip ::1/Require all granted/g' /etc/httpd/conf.d/phpMyAdmin.conf \
&& sed -i 's/Allow from 127.0.0.1/Allow from all/g' /etc/httpd/conf.d/phpMyAdmin.conf \
&& sed -i "s/'cookie'/'config'/g" /etc/phpMyAdmin/config.inc.php \
&& sed -i "s/\['user'\] .*= '';/\['user'\] = 'root';/g" /etc/phpMyAdmin/config.inc.php \
&& sed -i "/AllowNoPassword.*/ {N; s/AllowNoPassword.*FALSE/AllowNoPassword'] = TRUE/g}" /etc/phpMyAdmin/config.inc.php
# --------- Advanced Utilities ------------#
RUN curl --silent --location https://rpm.nodesource.com/setup_6.x | bash - \
&& yum -y install nodejs gcc-c++ make ruby php5-intl xdebug sqlite-devel ruby-devel\
&& npm install -g npm \
&& curl -sS https://getcomposer.org/installer | php \
&& mv composer.phar /usr/local/bin/composer && gem install mailcatcher

# --------- Drush ------------#
RUN yum install -y wget && wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar \
&& chmod +x drush.phar \
&& mv drush.phar /usr/local/bin/drush && composer global require drush/drush:8.1.16 -vvv

# --------- Container Config ------------#
COPY Scripts/supervisord.conf /etc/supervisord.conf
COPY Scripts/entry.sh /entry.sh
COPY Scripts/memcached /etc/sysconfig/memcached
RUN chmod +x /entry.sh \
&& sed -i "s/vactory8_db_user/${database_user}/g" /entry.sh \
&& sed -i "s/vactory8_db/${database_name}/g" /entry.sh \
&& sed -i "s/voidtech/${database_user_psswd}/g" /entry.sh

ENTRYPOINT ["/entry.sh"]
