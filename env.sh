#!/usr/bin/env bash

export DATABASE=${DATABASE_NAME:-"hat211"}
export DBUSER=${DATABASE_USER:-$DATABASE}
export DBPASS=${DATABASE_PASSWORD:-"pa55w0rd"}

export POSTGRES_DB=$DATABASE
export POSTGRES_USER=$DBUSER
export POSTGRES_PASSWORD=$DBPASS
export POSTGRES_HOST=${DATABASE_SERVER:-"localhost"}
export POSTGRES_PORT=${DATABASE_PORT:-"5432"}

export JDBCURL="jdbc:postgresql://$POSTGRES_HOST:$POSTGRES_PORT/$DATABASE"