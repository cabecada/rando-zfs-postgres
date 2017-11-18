#!/bin/sh

set -e
set -x

sysrc zfs_enable="YES"
service zfs start

if ! zpool list -H | grep -q pool1 ; then
    zpool create pool1 /dev/ada1
fi

pkg install -y postgresql96-server

DATASET=pool1/db
if ! zfs list -H | grep -q "$DATASET"; then
    zfs create -o mountpoint=/db "$DATASET"
    zfs set atime=off "$DATASET"
    zfs set compression=lz4 "$DATASET"
    zfs set recordsize=16K "$DATASET"
    zfs set primarycache=metadata "$DATASET"
fi

BASEDB=pool1/db/basedb
if ! zfs list -H | grep -q "$BASEDB" ; then
    zfs create -o mountpoint=/db/basedb "$BASEDB"
fi

chown postgres:postgres /db/basedb

sysrc postgresql_enable="YES"
sysrc postgresql_data="/db/basedb"
if ! su postgres -c "pg_ctl status -D /db/basedb" ; then
    su postgres -c "initdb --no-locale -E UTF8 -n -N -D /db/basedb"
    service postgresql start
fi
