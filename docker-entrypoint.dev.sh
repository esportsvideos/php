#!/bin/sh
set -e
PROJECT_DIR=/var/www

uid=$(stat -c %u $PROJECT_DIR)
gid=$(stat -c %g $PROJECT_DIR)
user=www-data

if [ $uid == 0 ] && [ $gid == 0 ]; then
    if [ $# -eq 0 ]; then
        php-fpm --allow-to-run-as-root
    else
        echo "$@"
        exec "$@"
        exit
    fi
fi

sed -i -r "s/$user:x:[0-9]+:[0-9]+:/$user:x:$uid:$gid:/g" /etc/passwd
sed -i -r "s/$user:x:[0-9]+:/$user:x:$gid:/g" /etc/group

chown -R $uid:$gid /home/www-data $PROJECT_DIR

if [ $# -eq 0 ]; then
    php-fpm
else
    echo su-exec $user "$@"
    exec su-exec $user "$@"
fi
