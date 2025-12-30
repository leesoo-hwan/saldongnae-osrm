#!/usr/bin/env bash
set -e

OSRM_BASENAME="/data/south-korea.osrm"

if [ ! -f "${OSRM_BASENAME}" ]; then
  echo "Preprocessing OSRM data..."
  osrm-extract -p /opt/car.lua /data/south-korea.osm.pbf
  osrm-partition "${OSRM_BASENAME}"
  osrm-customize "${OSRM_BASENAME}"
fi

exec osrm-routed --algorithm mld "${OSRM_BASENAME}" --max-table-size 8000
