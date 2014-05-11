FROM debian:wheezy

# enable false as no-login shell
RUN echo "/bin/false" >> /etc/shells

# update package manager
RUN apt-get update -q

# install common software
RUN apt-get install -y --force-yes --no-install-recommends \
    openssl selinux-basics selinux-policy-default auditd \
    mysql-client mysql-server \
    php5 php5-memcached php5-mysql php-apc memcached \
    apache2 libapache2-modsecurity \
    postfix dovecot-common dovecot-pop3d dovecot-imapd libsasl2-2 libsasl2-modules sasl2-bin \
    supervisor cron unzip puppet wget vsftpd logwatch

RUN mkdir -p /var/log/php
RUN mkdir -p /var/run/vsftpd/empty
RUN chown root:root /var/run/vsftpd/empty
RUN chmod 0660 /var/run/vsftpd/empty
RUN a2enmod mod-security
RUN a2enmod ssl
RUN cp -R /usr/share/logwatch/default.conf/logfiles/* /etc/logwatch/conf/logfiles/
RUN cp -R /usr/share/logwatch/default.conf/services/* /etc/logwatch/conf/services/

# a system user for memcached
RUN adduser memcached --shell /bin/false --no-create-home --disabled-login --system
RUN adduser email --shell /bin/false --no-create-home --disabled-login --system
RUN adduser ftpsecure --shell /bin/false --no-create-home --disabled-login --system

# load config files
ADD supervisor/supervisord.conf /etc/supervisor/supervisord.conf

ADD memcache/memcached.conf /etc/memcached.conf

ADD vsftpd/vsftpd.conf /etc/vsftpd.conf

ADD php/php.ini /etc/php5/apache2/php.ini

ADD mysql/mysql.conf /etc/mysql/my.cnf

ADD apache2/apache2.conf /etc/apache2/apache2.cnf
ADD apache2/envvars /etc/apache2/envvars
ADD apache2/apache-blog.conf /etc/apache2/sites-enabled/000-blog

ADD system/sysctl.conf /etc/sysctl.conf

ADD dovecot/conf.d/10-auth.conf /etc/dovecot/conf.d/10-auth.conf
ADD dovecot/conf.d/10-mail.conf /etc/dovecot/conf.d/10-mail.conf
ADD dovecot/conf.d/10-master.conf /etc/dovecot/conf.d/10-master.conf
ADD dovecot/conf.d/10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf
ADD dovecot/conf.d/auth-system.conf.ext /etc/dovecot/conf.d/auth-system.conf.ext
ADD dovecot/dovecot.conf /etc/dovecot/dovecot.conf

ADD postfix/sasl/smtpd.conf /etc/postfix/sasl/smtpd.conf
ADD postfix/main.cf /etc/postfix/main.cf
ADD postfix/master.cf /etc/postfix/master.cf

ADD cron/puppet /etc/cron.hourly/puppet
ADD cron/backup /etc/cron.daily/backup

ADD start.sh /start.sh

RUN rm -f /etc/apache2/sites-enabled/000-default
RUN chmod +x /start.sh /etc/cron.hourly/puppet /etc/cron.daily/backup
RUN chown -R root:root /etc/postfix/ /etc/dovecot/ /etc/supervisor/ /etc/php5/ /etc/apache2/ /etc/mysql/ /etc/cron.hourly/ /etc/sysctl.conf /etc/memcached.conf /etc/vsftpd.conf /start.sh

# ports (ftp, http, https, imaps, smtp, passive ftp)
EXPOSE 20 21 80 443 993 587 10000 10001 10002 10003 10004 10005 10006 10007 10008 10009

CMD ['/start.sh']
