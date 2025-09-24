#!/bin/bash
set -e

CONTAINER=oracle_m1_s1_bdd
DB=bdd   # ⚠️ service name en minuscule

echo "➡️ Running init.sql inside $CONTAINER..."

docker exec -i $CONTAINER sqlplus system/root@//localhost:1521/$DB @/scripts/init.sql

echo "✅ Database initialized using init.sql."
