#!/usr/bin/env bash

if [[ -d /sqlmaster/ ]]; then
  chown -R mssql:mssql /sqlmaster
fi

if [[ -d /sqldata/ ]]; then
  chown -R mssql:mssql /sqldata
fi

/opt/mssql/bin/sqlservr