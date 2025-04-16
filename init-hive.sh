#!/usr/bin/bash
docker compose -p air-quality-prediction exec hiveserver2 beeline -u 'jdbc:hive2://localhost:10000/' -f /var/ddl/tables.sql