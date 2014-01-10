Exec{ path => ['/usr/bin/', '/usr/local/bin/', '/usr/sbin/', '/bin'], }

exec { 'apt-get update':
    user => root,
}

package {[
    'haproxy',
    'htop',
    'vim',
    'redir',
    'wget',
    ]:
    ensure  => latest,
    require => Exec['apt-get update'],
}

exec { 'docker_install':
    command => 'wget -qO- http://get.docker.io | sh',
    user    => root,
    creates => '/usr/bin/docker',
    require => Package['wget'],
}

group { 'docker':
    ensure => present,
}

user { 'root':
    ensure  => present,
    groups  => ['docker'],
    require => Group['docker'],
}

service { 'docker':
    ensure   => running,
    enable   => true,
    require  => [
        Exec['docker_install'],
        User['root'],
    ],
}

file { '/etc/default/haproxy':
    source => "puppet:///modules/haproxy/default",
    owner  => root,
    group  => root,
    mode   => 0644,
    notify => Service['haproxy'],
}

file { '/etc/haproxy/haproxy.cfg':
    source  => "puppet:///modules/haproxy/haproxy.cfg",
    owner   => root,
    group   => root,
    mode    => 0644,
    require => Package['haproxy'],
    notify  => Service['haproxy'],
}

service { 'haproxy':
    ensure  => running,
    enable  => true,
    require => [
        Package['haproxy'],
        File['/etc/default/haproxy', '/etc/haproxy/haproxy.cfg'],
    ],
}
