#!/bin/bash

set -e

psql -U root -h localhost -p 5432 -f warehouse_schema.sql core