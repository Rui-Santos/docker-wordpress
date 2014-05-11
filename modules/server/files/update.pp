
Exec {
    path => [ '/bin', '/usr/bin', '/usr/sbin', '/usr/local/bin', ],
    user => root,
}

File {
    owner => root,
    group => root,
}

define new_user($user, $password) {
    
    exec { "${user}_add_mail_address":
        command => "echo \"${user}@${domain} ${domain}/${user}/\" >> /mails/vmaps",
        require => File['/mails/vmaps'],
        unless  => "grep -c \"${user}@${domain}\" /mails/vmaps",
        notify  => Exec["${user}_generate_vmaps"],
    }
    
    exec { "${user}_add_user":
        command => "echo \"${user}:::::::\" >> /mails/users",
        require => File['/mails/users'],
        unless  => "grep -c \"${user}\" /mails/users",
    }
    
    exec { "${user}_add_passwd":
        command => "echo \"${user}@${domain}:`doveadm pw -s ssha512 -u ${user} -p ${password}`\" >> /mails/passwd",
        require => File['/mails/passwd'],
        unless  => "grep -c \"${user}@${domain}\" /mails/passwd",
    }
    
    exec { "${user}_generate_vmaps":
        command => 'postmap /mails/vmaps',
        require => [File['/mails/vmaps'], Exec["${user}_add_mail_address"]],
    }
    
}

file { ['/mails']: ensure => directory, }
file { ['/mails/passwd', '/mails/users', '/mails/vmaps']: ensure => present, require => File['/mails'], }

new_user { 'webmaster':  user => 'webmaster', password => 'webmaster', }
