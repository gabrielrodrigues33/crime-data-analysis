#!/bin/bash

set -e
USE_REMOTE=${1:-""}

CONNECTION_STRING="postgres://root:root@localhost:5432/core?sslmode=disable"
if [ "$USE_REMOTE" == "remote" ]; then 
    CONNECTION_STRING="postgres://${DB_USER}:$DB_PASSWORD@$DB_HOST:5432/$DB_NAME?sslmode=disable" 
fi

psql $CONNECTION_STRING -f warehouse_schema.down.sql core
psql $CONNECTION_STRING -f warehouse_schema.up.sql core