#!/bin/bash

set -e

function setup {
  while [[ ! -e /tmp/postgresql.pid ]]; do
    sleep 1
  done

  psql -U postgres -d template1 -q < /database-initialize.sql
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
