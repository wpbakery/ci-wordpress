#!/bin/bash
set -m

# Start apache2
# /usr/sbin/apachectl -D FOREGROUND

# Start mysql
# service mysql start
# exec mysqld_safe
exec supervisord -n

# now we bring the primary process back into the foreground
# and leave it there
fg %1