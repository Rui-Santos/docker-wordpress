Exec{ path => ['/usr/bin/', '/usr/local/bin/', '/usr/sbin/', '/bin'], }

exec { 'apt-get update':
    user => root,
}

package {[
    'haproxy',
    'htop',
    'vim',
    'lxc',
    'redir',
    'cgroup-lite',
    'wget',
    ]:
    ensure  => latest,
    require => Exec['apt-get update'],
}

exec { 'docker_install':
    command => 'wget --output-document=docker https://get.docker.io/builds/Linux/x86_64/docker-latest && chmod +x /usr/bin/docker',
    cwd     => '/usr/bin',
    user    => root,
    creates => '/usr/bin/docker',
    require => Package['wget'],
}

file { '/etc/init/docker-daemon.conf':
    source => "puppet:///modules/docker/docker.upstart",
    owner  => root,
    group  => root,
    mode   => 0755,
    notify => Service['docker-daemon'],
}

group { 'docker':
    ensure => present,
}

user { 'root':
    ensure  => present,
    groups  => ['docker'],
    require => Group['docker'],
}

service { 'docker-daemon':
    ensure  => running,
    require => [
        Exec['docker_install'],
        User['root'],
        File['/etc/init/docker-daemon.conf'],
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
    require => [
        Package['haproxy'],
        File['/etc/default/haproxy', '/etc/haproxy/haproxy.cfg'],
    ],
}
