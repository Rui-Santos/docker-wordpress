
Exec {
    path => [ '/bin', '/usr/bin', '/usr/sbin', '/usr/local/bin', ],
    user => root,
}

File {
    owner => root,
    group => root,
}

exec { 'postfix_domain':
    command => "sed -i 's/##DOMAIN##/${domain}/g' /etc/postfix/main.cf",
    unless  => "grep -c ${domain} /etc/postfix/main.cf",
}

file { ['/mails', '/var/log/apache2', '/var/log/supervisor', '/var/cache/puppet']:   ensure => directory, }
file { ['/mails/valiases']: ensure => present, require => File['/mails'], }

exec { 'generate_valiases':
    command => 'postmap /mails/valiases',
    require => File['/mails/valiases'],
}
exec { 'apply_domain':
    command => 'echo "${domain}" > /mails/vhosts',
    creates => '/mails/vhosts',
    notify  => Exec['generate_vhosts'],
    require => File['/mails'],
}
exec { 'generate_vhosts':
    command => 'postmap /mails/vhosts',
    onlyif  => ['test -f /mails/vhosts'],
    require => Exec['apply_domain'],
}
exec { 'set_fqdn':
    command => 'sed -i "s/${hostname}/${domain}/g" /etc/hosts && touch /var/cache/puppet/set_fqdn',
    creates => '/var/cache/puppet/set_fqdn',
    require => File['/var/cache/puppet'],
}
exec { 'set_apache_domain':
    command => 'sed -i "s/##DOMAIN##/${domain}/g" /etc/apache2/envvars && touch /var/cache/puppet/set_apache_domain',
    creates => '/var/cache/puppet/set_apache_domain',
    require => File['/var/cache/puppet'],
}

file { '/var/www/wordpress/wp-config.php':
    source => 'puppet:///modules/server/wp-config.php',
    group  => 'www-data',
    owner  => 'www-data',
}

exec { 'mysql_install_db':
    command => "mysql_install_db \
                && touch /var/cache/puppet/mysql_install_db",
    creates => '/var/cache/puppet/mysql_install_db',
    require => File['/var/cache/puppet'],
}
exec { 'mysql_root_password':
    command => "openssl rand -base64 24 > /tmp/.mysql-password \
                && touch /var/cache/puppet/mysql_root_password",
    creates => '/var/cache/puppet/mysql_root_password',
    require => File['/var/cache/puppet'],
}
exec { 'backup_set_password':
    command => "sed -i \"s/__PASSWORD__/$(cat /tmp/.mysql-password | tr '/' '_')/g\" /etc/cron.daily/backup \
                && touch /var/cache/puppet/backup_set_password",
    require => Exec['mysql_install_db', 'mysql_root_password'],
    creates => '/var/cache/puppet/backup_set_password',
}
service { 'mysql':
    ensure => running,
    require => Exec['mysql_install_db'],
}
exec { 'mysql_init_wordpress':
    command => "mysql -u root -e \"CREATE DATABASE wordpress; GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost' \
                IDENTIFIED BY 'wordpress' WITH GRANT OPTION; FLUSH PRIVILEGES;\" \
                && touch /var/cache/puppet/mysql_init_wordpress",
    require => [Service['mysql'], File['/var/cache/puppet']],
    creates => '/var/cache/puppet/mysql_init_wordpress',
}
exec { 'mysql_set_password':
    command => "mysql -u root -e \"SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$(cat /tmp/.mysql-password | tr '/' '_')');\" \
                && touch /var/cache/puppet/mysql_set_password",
    require => Exec['mysql_init_wordpress', 'mysql_root_password'],
    creates => '/var/cache/puppet/mysql_set_password',
}
exec { 'shutdown_mysql':
    command => 'killall mysqld',
    require => [Service['mysql'], Exec['mysql_init_wordpress', 'mysql_set_password']],
    onlyif  => ['test -f /tmp/.mysql-password'],
}
file { '/tmp/.mysql-password':
    ensure  => absent,
    require => Exec['mysql_set_password', 'backup_set_password', 'shutdown_mysql'],
}

exec { 'create_wp_keys':
    command => "echo '<?php ' > /var/www/wordpress/wp-keys.php && wget -qO- http://api.wordpress.org/secret-key/1.1/salt/ >> /var/www/wordpress/wp-keys.php",
    creates => '/var/www/wordpress/wp-keys.php',
}

exec { 'chown_wp_keys':
    command => 'chown www-data: -R /var/www/',
    require => [Exec['create_wp_keys'], File['/var/www/wordpress/wp-config.php']],
}

file { '/var/cache/puppet/init':
    ensure  => present,
    require => [Exec['chown_wp_keys'], File['/tmp/.mysql-password']],
}
