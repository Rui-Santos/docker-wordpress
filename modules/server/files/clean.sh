#!/bin/bash

basedir=`dirname $0`

. "${basedir}/vars.sh"

docker stop $container_name
docker rm $container_name
rm -fr ${basedir}/logs/*
rm -fr ${basedir}/mysql/*
