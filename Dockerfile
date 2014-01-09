FROM ubuntu

RUN apt-get update
RUN apt-get install -y apache2 php5 php5-mysql mysql-server mysql-client openssh-server unzip
RUN mkdir /var/run/sshd
ADD ./start-services.sh /start.sh
RUN chmod +x /start.sh

ADD http://de.wordpress.org/wordpress-3.8-de_DE.zip /wordpress.zip
RUN unzip /wordpress.zip
RUN rm /var/www/index.html
RUN cp -R /wordpress/* /var/www/
RUN rm -fr /wordpress
ADD ./wp-config.php /var/www/wp-config.php
RUN echo "<?php " > /var/www/wp-keys.php && wget -qO- https://api.wordpress.org/secret-key/1.1/salt/ >> /var/www/wp-keys.php
RUN sed -i 's#<< KEYS >>#include "wp-keys.php";#g' /var/www/wp-config.php

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

EXPOSE 22
EXPOSE 80

CMD ['/start.sh']
