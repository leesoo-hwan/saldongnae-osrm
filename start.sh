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

download_pbf () {
  echo "Downloading PBF to: ${PBF_PATH}"

  # 1) wget
  if command -v wget >/dev/null 2>&1; then
    wget -O "${PBF_PATH}.tmp" "${PBF_URL}"
    mv "${PBF_PATH}.tmp" "${PBF_PATH}"
    return 0
  fi

  # 2) busybox wget
  if command -v busybox >/dev/null 2>&1; then
    if busybox wget --help >/dev/null 2>&1; then
      busybox wget -O "${PBF_PATH}.tmp" "${PBF_URL}"
      mv "${PBF_PATH}.tmp" "${PBF_PATH}"
      return 0
    fi
  fi

  # 3) python3 urllib (마지막 폴백)
  if command -v python3 >/dev/null 2>&1; then
    python3 - <<'PY'
import os, sys, urllib.request
url = os.environ["PBF_URL"]
tmp = os.environ["PBF_PATH"] + ".tmp"
dst = os.environ["PBF_PATH"]
urllib.request.urlretrieve(url, tmp)
os.replace(tmp, dst)
PY
    return 0
  fi

  echo "ERROR: No downloader available (wget/busybox/python3)."
  exit 1
}

if [ ! -f "${OSRM_BASENAME}" ]; then
  echo "No OSRM data found. Start preprocessing..."

  if [ ! -f "${PBF_PATH}" ]; then
    export PBF_URL PBF_PATH
    download_pbf
  else
    echo "PBF already exists: ${PBF_PATH}"
  fi

  osrm-extract -p "${PROFILE}" "${PBF_PATH}"
  osrm-partition "${OSRM_BASENAME}"
  osrm-customize "${OSRM_BASENAME}"
fi

exec osrm-routed --algorithm "${ALGO}" "${OSRM_BASENAME}" --max-table-size 8000
