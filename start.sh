#!/usr/bin/env bash
set -euo pipefail

REGION_NAME="${REGION_NAME:-south-korea}"
PBF_PATH="/data/${REGION_NAME}.osm.pbf"
OSRM_BASENAME="/data/${REGION_NAME}.osrm"

PROFILE="${PROFILE:-/opt/car.lua}"
ALGO="${ALGO:-mld}"

echo "== OSRM Fly boot =="
echo "REGION_NAME=${REGION_NAME}"
echo "PBF_PATH=${PBF_PATH}"
echo "PROFILE=${PROFILE}"
echo "ALGO=${ALGO}"

if [ ! -f "${PBF_PATH}" ]; then
  echo "ERROR: PBF file not found at ${PBF_PATH}"
  echo "Hint: Make sure Dockerfile uses: ADD <PBF_URL> ${PBF_PATH}"
  exit 1
fi

if [ ! -f "${OSRM_BASENAME}" ]; then
  echo "No OSRM data found. Start preprocessing..."
  osrm-extract -p "${PROFILE}" "${PBF_PATH}"
  osrm-partition "${OSRM_BASENAME}"
  osrm-customize "${OSRM_BASENAME}"
fi

exec osrm-routed --algorithm "${ALGO}" "${OSRM_BASENAME}" --max-table-size 8000 --port 5000
