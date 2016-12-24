#!/bin/bash

set -e

# Prepare the test databases in Travis CI.
# The script should be run with sudo.
# The script is not idempotent: it assumes the machine in a clean state
# and is designed for a sudo-enabled Trusty environment.

set_param () {
    # Set a parameter in a postgresql.conf file
    version=$1
    param=$2
    value=$3

    sed -i "s/^\s*#\?\s*$param.*/$param = $value/" \
        "/etc/postgresql/$version/psycopg/postgresql.conf"
}

create () {
    version=$1
    port=$2
    dbname=psycopg2_test

    pg_createcluster -p $port --start-conf manual $version psycopg
    set_param "$version" max_prepared_transactions 10
    pg_ctlcluster "$version" psycopg start

    sudo -u postgres psql -c "create user travis" "port=$port"
    sudo -u postgres psql -c "create database $dbname" "port=$port"
    sudo -u postgres psql -c "grant create on database $dbname to travis" "port=$port"
    sudo -u postgres psql -c "create extension hstore" "port=$port dbname=$dbname"
}


# Would give a permission denied error in the travis build dir
cd /

create 9.6 54396
create 9.5 54395
create 9.4 54394
create 9.3 54393
create 9.2 54392