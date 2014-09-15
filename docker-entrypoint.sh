#!/bin/bash

set -e

function pg_cmd {
  psql -qe -U postgres -d template1 -c "${1}"
}

function setup {
  while [[ ! -e /tmp/postgresql.pid ]]; do
    sleep 1
  done

  for extension in $DB_EXTENSIONS; do
    pg_cmd "CREATE EXTENSION ${extension};"
  done
  pg_cmd "CREATE USER ${DB_USER} WITH SUPERUSER ENCRYPTED PASSWORD '${DB_PASS}';"
  pg_cmd "CREATE DATABASE ${DB_NAME} TEMPLATE template1 OWNER ${DB_USER};"
}

if [[ "$1" == 'postgres' ]]; then
  chown -R postgres "$PGDATA"

  if [[ -z "$(ls -A "$PGDATA")" ]]; then
    gosu postgres initdb

    cat /custom.postgresql.conf >> "$PGDATA/postgresql.conf"
    rm /custom.postgresql.conf

    { echo; echo 'host all all 0.0.0.0/0 trust'; } >> "$PGDATA"/pg_hba.conf

    setup &
  fi

  exec gosu postgres "$@"
fi

exec "$@"
