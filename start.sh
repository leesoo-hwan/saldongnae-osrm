#!/usr/bin/env bash
set -euo pipefail

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

if [ ! -f "${OSRM_BASENAME}" ]; then
  echo "No OSRM data found. Start preprocessing..."

  # ✅ Dockerfile에서 이미 PBF를 넣었으면 여기서는 다운로드 안 함
  if [ ! -f "${PBF_PATH}" ]; then
    echo "PBF not found at ${PBF_PATH}. (No downloader in image) -> build must include PBF."
    exit 1
  fi

  osrm-extract -p "${PROFILE}" "${PBF_PATH}"
  osrm-partition "${OSRM_BASENAME}"
  osrm-customize "${OSRM_BASENAME}"
fi

exec osrm-routed --algorithm "${ALGO}" "${OSRM_BASENAME}" --max-table-size "${MAX_TABLE_SIZE}"
