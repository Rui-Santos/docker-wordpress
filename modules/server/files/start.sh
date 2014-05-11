#!/bin/bash

basedir=`dirname $0`

. "${basedir}/vars.sh"

docker start $container_name
