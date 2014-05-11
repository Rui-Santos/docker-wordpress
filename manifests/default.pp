Exec {
    path => [ '/usr/bin/', '/bin', '/usr/local/bin/', ],
}

exec { 'apt-get update':
    user => root,
} ->

package { [
    'g++',
    'lxc',
    'cgroup-lite',
    'redir',
    'python-pip',
    'python-software-properties',
    'curl',
    'htop',
    'wget',
    'git',
    'build-essential',
    'nodejs',
    'docker.io',
    ]:
    ensure => latest,
} ->

file { '/usr/bin/node':
    ensure => link,
    target => '/usr/bin/nodejs',
} ->

file { '/usr/bin/docker':
    ensure => link,
    target => '/usr/bin/docker.io',
} ->

user { 'vagrant':
    ensure => present,
    groups => ['docker'],
}
