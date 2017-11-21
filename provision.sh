#!/bin/sh

set -e
set -x

sysrc zfs_enable="YES"
service zfs start

if ! zpool list -H | grep -q pool1 ; then
    zpool create pool1 /dev/ada1
fi

pkg install -y postgresql96-server postgresql96-contrib

DATASET=pool1/db
if ! zfs list -H | grep -q "$DATASET"; then
    zfs create -o mountpoint=/db "$DATASET"
    zfs set atime=off "$DATASET"
    zfs set compression=lz4 "$DATASET"
    zfs set recordsize=16K "$DATASET"
    zfs set primarycache=metadata "$DATASET"
fi

CLUSTER=pool1/db/cluster1
if ! zfs list -H | grep -q "$CLUSTER" ; then
    zfs create -o mountpoint=/db/cluster1 "$CLUSTER"
fi

chown postgres:postgres /db/cluster1

sysrc postgresql_enable="YES"
sysrc postgresql_data="/db/cluster1"
if ! su postgres -c "pg_ctl status -D /db/cluster1" ; then
    su postgres -c "initdb --no-locale -E UTF8 -n -N -D /db/cluster1"
    cp /vagrant/pg_hba.conf /db/cluster1/pg_hba.conf
    cp /vagrant/postgresql.conf /db/cluster1/postgresql.conf
    chown postgres:postgres /db/cluster1/pg_hba.conf /db/cluster1/postgresql.conf
    service postgresql start
fi
