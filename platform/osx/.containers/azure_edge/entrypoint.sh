#!/usr/bin/env sh

if [ -d /sqlmaster/ ]; then
  chown -R mssql:mssql /sqlmaster
fi