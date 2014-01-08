FROM ubuntu

RUN apt-get update
RUN apt-get install -y apache2 php5 php5-mysql mysql-server mysql-client openssh-server
RUN mkdir /var/run/sshd
ADD ./start-services.sh /start.sh
RUN chmod +x /start.sh

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

EXPOSE 22
EXPOSE 80

CMD ['/start.sh']
