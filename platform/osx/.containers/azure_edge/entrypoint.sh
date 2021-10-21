#!/bin/sh

if [ -d /sqlmaster/ ]; then
  chown -R mssql:mssql /sqlmaster
fi

/opt/mssql/bin/sqlservr