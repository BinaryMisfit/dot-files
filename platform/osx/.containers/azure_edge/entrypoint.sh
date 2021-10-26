#!/usr/bin/env bash
printf "Running SQL Server"
if [[ -d /sqldata ]]; then
  chown -R mssql: /sqldata
fi

if [[ -d /var/opt/mssql/data ]]; then
  chown -R mssql: /var/opt/mssql/data
fi

exec /opt/mssql/bin/sqlservr