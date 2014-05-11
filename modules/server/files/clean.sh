#!/bin/bash

basedir=`dirname $0`

. "${basedir}/vars.sh"

docker stop $container_name
docker rm $container_name
rm -fr ${basedir}/logs/supervisor/*
rm -fr ${basedir}/logs/apache2/*
rm -fr ${basedir}/mysql/*
