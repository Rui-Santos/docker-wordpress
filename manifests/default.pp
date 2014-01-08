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
    'git',
    'build-essential',
    ]:
    ensure => latest,
} ->

exec { 'docker_install':
    command => 'wget --output-document=docker https://get.docker.io/builds/Linux/x86_64/docker-latest && chmod +x /usr/bin/docker',
    cwd => '/usr/bin',
    user => root,
    creates => '/usr/bin/docker',
} ->

file { '/etc/init/docker-daemon.conf':
    source => "puppet:///modules/docker_image_builder/docker_daemon.upstart",
    owner => root,
    group => root,
    mode => 0755,
    notify => Service['docker-daemon'],
} ->

group { 'docker':
    ensure => present,
} ->

user { 'vagrant':
    ensure => present,
    groups => ['docker'],
} ->

service { 'docker-daemon':
    ensure => running,
}