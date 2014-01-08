#!/bin/bash
/usr/sbin/apache2 -k start &
/usr/sbin/mysqld &
/usr/sbin/sshd -D
