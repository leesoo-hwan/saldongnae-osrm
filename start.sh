#!/usr/bin/env bash
set -euo pipefail

REGION_NAME="${REGION_NAME:-south-korea}"
PBF_URL="${PBF_URL:-https://download.geofabrik.de/asia/south-korea-latest.osm.pbf}"
PBF_PATH="/data/${REGION_NAME}.osm.pbf"
OSRM_BASENAME="/data/${REGION_NAME}.osrm"

PROFILE="${PROFILE:-/opt/car.lua}"
ALGO="${ALGO:-mld}"

echo "== OSRM Fly boot =="
echo "REGION_NAME=${REGION_NAME}"
echo "PBF_URL=${PBF_URL}"
echo "PROFILE=${PROFILE}"
echo "ALGO=${ALGO}"

if [ ! -f "${OSRM_BASENAME}" ]; then
  echo "No OSRM data found. Start preprocessing..."

  if [ ! -f "${PBF_PATH}" ]; then
    curl -L --fail --retry 5 --retry-delay 3 -o "${PBF_PATH}" "${PBF_URL}"
  fi

  osrm-extract -p "${PROFILE}" "${PBF_PATH}"
  osrm-partition "${OSRM_BASENAME}"
  osrm-customize "${OSRM_BASENAME}"
fi

exec osrm-routed --algorithm "${ALGO}" "${OSRM_BASENAME}" --max-table-size 8000
