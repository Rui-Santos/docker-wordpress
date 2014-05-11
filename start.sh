#!/bin/bash

# execute initial setup
if [ ! -f /var/cache/puppet/init ]; then
    /usr/bin/puppet apply /puppet/modules/server/manifests/init.pp --modulepath=/puppet/modules
fi

# execute updates
. /etc/cron.hourly/puppet

# start all services
/usr/bin/supervisord
