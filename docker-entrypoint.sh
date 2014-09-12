#!/bin/bash

set -e

if [[ "$1" == 'postgres' ]]; then
  chown -R postgres "$PGDATA"

  if [[ -z "$(ls -A "$PGDATA")" ]]; then
    gosu postgres initdb

    cat /custom.postgresql.conf >> "$PGDATA/postgresql.conf"
    rm /custom.postgresql.conf

    { echo; echo 'host all all 0.0.0.0/0 trust'; } >> "$PGDATA"/pg_hba.conf
  fi

  exec gosu postgres "$@"
fi

exec "$@"
