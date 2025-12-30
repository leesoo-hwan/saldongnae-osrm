#!/bin/sh
set -eu

REGION_NAME="${REGION_NAME:-south-korea}"
PBF_URL="${PBF_URL:-https://download.geofabrik.de/asia/south-korea-latest.osm.pbf}"
PBF_PATH="/data/${REGION_NAME}.osm.pbf"
OSRM_BASENAME="/data/${REGION_NAME}.osrm"

PROFILE="${PROFILE:-/opt/car.lua}"
ALGO="${ALGO:-mld}"
MAX_TABLE_SIZE="${MAX_TABLE_SIZE:-8000}"

echo "== OSRM Fly boot =="
echo "REGION_NAME=${REGION_NAME}"
echo "PBF_URL=${PBF_URL}"
echo "PBF_PATH=${PBF_PATH}"
echo "PROFILE=${PROFILE}"
echo "ALGO=${ALGO}"
echo "MAX_TABLE_SIZE=${MAX_TABLE_SIZE}"

download_pbf() {
  echo "Downloading PBF to: ${PBF_PATH}"
  if command -v curl >/dev/null 2>&1; then
    curl -L --fail --retry 5 --retry-delay 3 -o "${PBF_PATH}" "${PBF_URL}"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "${PBF_PATH}" "${PBF_URL}"
  else
    echo "ERROR: No downloader available (curl/wget)."
    exit 1
  fi
}

if [ ! -f "${OSRM_BASENAME}" ]; then
  echo "No OSRM data found. Start preprocessing..."

  if [ ! -f "${PBF_PATH}" ]; then
    download_pbf
  else
    echo "PBF already exists: ${PBF_PATH}"
  fi

  echo "Running osrm-extract..."
  osrm-extract -p "${PROFILE}" "${PBF_PATH}"

  echo "Running osrm-partition..."
  osrm-partition "${OSRM_BASENAME}"

  echo "Running osrm-customize..."
  osrm-customize "${OSRM_BASENAME}"
fi

echo "Starting osrm-routed..."
exec osrm-routed --algorithm "${ALGO}" "${OSRM_BASENAME}" --max-table-size "${MAX_TABLE_SIZE}"
