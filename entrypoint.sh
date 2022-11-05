#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -x

: "${DJANGO_DATABASE_HOST:=db}"
: "${DJANGO_DATABASE_PORT:=5432}"

# We need this line to make sure that this container is started
# after the one with postgres:
dockerize \
  -wait "tcp://${DJANGO_DATABASE_HOST}:${DJANGO_DATABASE_PORT}" \
  -timeout 90s

# It is also possible to wait for other services as well: redis, elastic, mongo
echo 'Postgres is up - continuing...'
pwd
ls -al

python manage.py makemigrations
python manage.py migrate

# https://stackoverflow.com/questions/12314451/accessing-bash-command-line-args-vs
# exec $@ or exec $* (without douple quotes), both work as well.
exec "$@"