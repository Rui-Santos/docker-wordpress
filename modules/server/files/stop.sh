#!/bin/bash

basedir=`dirname $0`

. "${basedir}/vars.sh"

docker stop $container_name
