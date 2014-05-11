
Exec {
    path => [ '/usr/bin/', '/bin', '/usr/local/bin/', '/usr/sbin/', ],
    user => root,
}

File {
    group => root,
    owner => root,
}

exec { 'apt-get update':
} ->

package { [
    'git',
    'docker.io',
    'cgroup-lite',
    'haproxy',
    'redir',
    'htop',
    'wget',
    'unzip',
    'logwatch',
    'proftpd',
    ]:
    ensure => latest,
}

file { ['/var/cache/puppet/', '/containers/']:
    ensure => directory,
}

exec { 'enable_memory_swap':
    command => 'sed \'s/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/g\' /etc/default/grub > \
                /etc/default/grub && touch /var/cache/puppet/enable_memory_swap',
    creates => '/var/cache/puppet/enable_memory_swap',
    require => File['/var/cache/puppet/'],
}

exec { 'update-grub':
    command => 'update-grub && touch /var/cache/puppet/update-grub',
    creates => '/var/cache/puppet/update-grub',
    require => File['/var/cache/puppet/'],
}

exec { 'set_lxc_driver':
    command => 'sed \'s/#DOCKER_OPTS="/DOCKER_OPTS="-e lxc /g\' /etc/default/docker.io > /etc/default/docker.io && touch /var/cache/puppet/set_lxc_driver',
    creates => '/var/cache/puppet/set_lxc_driver',
    require => [File['/var/cache/puppet/'], Package['docker.io']],
}

exec { 'enable_haproxy':
    command => 'sed -i s/ENABLED=0/ENABLED=1/g /etc/default/haproxy && touch /var/cache/puppet/enable_haproxy',
    creates => '/var/cache/puppet/enable_haproxy',
    require => [File['/var/cache/puppet/'], Package['haproxy']],
}

exec { 'enable_bin_false':
    command => 'echo "/bin/false" >> /etc/shells',
    unless  => 'grep -c /bin/false /etc/shells 2>/dev/null',
}

exec { 'download_wordpress':
    command => 'wget -q --output-document=/containers/wordpress.zip http://de.wordpress.org/wordpress-3.9-de_DE.zip',
    creates => '/containers/wordpress.zip',
    require => [File['/var/cache/puppet/', '/containers/'], Package['wget']],
}

file { '/containers/run.sh':
    source => 'puppet:///modules/server/run.sh',
}

file { '/containers/clean.sh':
    source => 'puppet:///modules/server/clean.sh',
}

file { '/containers/stop.sh':
    source => 'puppet:///modules/server/stop.sh',
}

file { '/containers/start.sh':
    source => 'puppet:///modules/server/start.sh',
}

file { '/containers/vars.sh':
    source => 'puppet:///modules/server/vars.sh',
}

file { '/containers/init.pp':
    source => 'puppet:///modules/server/init.pp',
}

file { '/containers/update.pp':
    source => 'puppet:///modules/server/update.pp',
}

file { '/containers/wp-config.php':
    source => 'puppet:///modules/server/wp-config.php',
}

file { '/usr/bin/add-blog.sh':
    source => 'puppet:///modules/server/add-blog.sh',
}

file { '/etc/haproxy/haproxy.cfg':
    source => 'puppet:///modules/haproxy/haproxy.cfg',
}

file { '/etc/default/haproxy':
    source => 'puppet:///modules/haproxy/default_haproxy',
}

file { '/containers/haproxy':
    source => 'puppet:///modules/server/haproxy',
}

file { '/containers/proftp':
    source => 'puppet:///modules/server/proftp',
}

exec { 'copy_logwatch':
    command => 'cp -R /usr/share/logwatch/default.conf/logfiles/* /etc/logwatch/conf/logfiles/ \
                && cp -R /usr/share/logwatch/default.conf/services/* /etc/logwatch/conf/services/ \
                && touch /var/cache/puppet/copy_logwatch',
    creates => '/var/cache/puppet/copy_logwatch',
    require => [File['/var/cache/puppet/'], Package['logwatch']],
}

service { 'haproxy':
    ensure  => running,
    enable  => true,
    require => [File['/etc/default/haproxy', '/etc/haproxy/haproxy.cfg'], Package['haproxy']],
}
