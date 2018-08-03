#!/bin/bash
set -e

if [ "$CREATE_USER_UID" -a "$CREATE_USER_GID" ]; then
	echo "Create 'site-owner' group with GID=$CREATE_USER_GID"
	groupadd -g $CREATE_USER_GID site-owner
	echo "Add 'www-data' user to group 'site-owner'"
	usermod -a -G site-owner www-data
	echo "Create 'site-owner' user with UID=$CREATE_USER_UID, GID=$CREATE_USER_GID"
	useradd -d /var/www -g $CREATE_USER_GID -s /bin/false -M -N -u $CREATE_USER_UID site-owner
fi

if [ $1 = 'extjob-runner' ]; then
	exec gosu site-owner:site-owner /usr/local/bin/extjob-runner -c /etc/extjob-runner.toml
fi

exec "$@"
