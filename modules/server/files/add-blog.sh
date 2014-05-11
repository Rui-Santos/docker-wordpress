#!/bin/bash

if [ "$1" = "" -o "$2" = "" ]; then
    echo "usage: add-blog <domain> <port>"
    exit 1
fi

port=$2
domain="$1"
name="${1//./_}"

mkdir -p /containers/$name/backups/
mkdir -p /containers/$name/certs/
mkdir -p /containers/$name/logs/
mkdir -p /containers/$name/mails/
mkdir -p /containers/$name/mysql/
mkdir -p /containers/$name/puppet/modules/server/files/
mkdir -p /containers/$name/puppet/modules/server/manifests/
mkdir -p /containers/$name/wordpress/

openssl genrsa -des3 -out /containers/$name/certs/cert.key 4096
openssl req -new -key /containers/$name/certs/cert.key -out /containers/$name/certs/cert.csr
cp /containers/$name/certs/cert{.key,.key.org}
openssl rsa -in /containers/$name/certs/cert.key.org -out /containers/$name/certs/cert.key
openssl x509 -req -days 365 -in /containers/$name/certs/cert.csr -signkey /containers/$name/certs/cert.key -out /containers/$name/certs/cert.crt

chmod 0600 /containers/$name/certs/*

unzip -q /containers/wordpress.zip -d /containers/$name/

cp /containers/*.sh /containers/haproxy /containers/$name/
cp /containers/*.pp /containers/$name/puppet/modules/server/manifests/
cp /containers/wp-config.php /containers/$name/puppet/modules/server/files/wp-config.php

sed -i "s/container_domain=/container_domain=${domain}/g" /containers/$name/vars.sh
sed -i "s/container_hostname=/container_hostname=${name}/g" /containers/$name/vars.sh
sed -i "s/container_port=/container_port=${port}/g" /containers/$name/vars.sh

sed -i "s/#http_acl/   acl ${name} hdr_dom(host) -i ${domain}\n&/g" /etc/haproxy/haproxy.cfg
sed -i "s/#http_use/   use_backend ${name}_http_cluster if ${name}\n&/g" /etc/haproxy/haproxy.cfg
sed -i "s/#https_acl/   acl ${name} hdr_dom(host) -i ${domain}\n&/g" /etc/haproxy/haproxy.cfg
sed -i "s/#https_use/   use_backend ${name}_https_cluster if ${name}\n&/g" /etc/haproxy/haproxy.cfg

sed -i "s/##name##/${name}/g" /containers/$name/haproxy
sed -i "s/##ftp-host-port1##/$[port+1]/g" /containers/$name/haproxy
sed -i "s/##ftp-host-port2##/$[port+2]/g" /containers/$name/haproxy
sed -i "s/##imap-host-port##/$[port+5]/g" /containers/$name/haproxy
sed -i "s/##smtp-host-port##/$[port+6]/g" /containers/$name/haproxy
sed -i "s/##ftp-guest-port1##/$[port+1+32768]/g" /containers/$name/haproxy
sed -i "s/##ftp-guest-port2##/$[port+2+32768]/g" /containers/$name/haproxy
sed -i "s/##http-guest-port##/$[port+3+32768]/g" /containers/$name/haproxy
sed -i "s/##https-guest-port##/$[port+4+32768]/g" /containers/$name/haproxy
sed -i "s/##imap-guest-port##/$[port+5+32768]/g" /containers/$name/haproxy
sed -i "s/##smtp-guest-port##/$[port+6+32768]/g" /containers/$name/haproxy
cat /containers/$name/haproxy >> /etc/haproxy/haproxy.cfg

haproxy -c -f /etc/haproxy/haproxy.cfg

if [ "$?" != "0" ]; then
    echo "haproxy config invalid"
    exit 1
fi

service haproxy reload
