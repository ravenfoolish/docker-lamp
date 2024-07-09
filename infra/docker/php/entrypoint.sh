#!/bin/sh
set -e

USER_ID=${WWWUSER:-1000}
GROUP_ID=${WWWGROUP:-1000}
USERNAME=${USERNAME:-myuser}

echo "Starting with UID: $USER_ID, GID: $GROUP_ID"

useradd -u "$USER_ID" -o -m "$USERNAME"
groupmod -g "$GROUP_ID" "$USERNAME"

export HOME=/home/"$USERNAME"

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- httpd-foreground "$@"
fi

exec "$@"
