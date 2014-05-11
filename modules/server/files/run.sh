#!/bin/bash

basedir=`dirname $0`

. "${basedir}/vars.sh"

docker run -i -t -d \
    -v /containers/$container_hostname/backups:/backups:rw \
    -v /containers/$container_hostname/certs:/etc/ssl/private:ro \
    -v /containers/$container_hostname/logs:/logs:rw \
    -v /containers/$container_hostname/mails:/mails:rw \
    -v /containers/$container_hostname/mysql:/mysql:rw \
    -v /containers/$container_hostname/puppet/modules:/puppet/modules:rw \
    -v /containers/$container_hostname/wordpress:/var/www/wordpress:rw \
    -e FACTER_DOMAIN=$container_domain \
    -p 127.0.0.1:$[container_port+0+32768]:80 \
    -p 127.0.0.1:$[container_port+1+32768]:443 \
    -p 0.0.0.0:$[container_port+2+32768]:993 \
    -p 0.0.0.0:$[container_port+3+32768]:587 \
    -m $container_memory \
    --name="$container_name" \
    -h $container_hostname \
    $container_image \
    $container_command
