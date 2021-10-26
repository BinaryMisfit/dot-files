#!/usr/bin/env bash
printf "Running SQL Server"
if [[ -d /sqldata/ ]]; then
  chown -R mssql: /sqldata/
fi

#exec /opt/mssql/bin/sqlservr