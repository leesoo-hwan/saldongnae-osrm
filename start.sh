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

download_pbf () {
  local url="$1"
  local out="$2"

  echo "Downloading PBF to: ${out}"

  if command -v curl >/dev/null 2>&1; then
    curl -L --fail --retry 5 --retry-delay 3 -o "${out}" "${url}"
    return 0
  fi

  if command -v wget >/dev/null 2>&1; then
    wget -O "${out}" "${url}"
    return 0
  fi

  if command -v busybox >/dev/null 2>&1; then
    # busybox 안에 wget이 있을 수 있음
    if busybox wget --help >/dev/null 2>&1; then
      busybox wget -O "${out}" "${url}"
      return 0
    fi
  fi

  if command -v python3 >/dev/null 2>&1; then
    python3 - <<PY
import urllib.request
url = "${url}"
out = "${out}"
urllib.request.urlretrieve(url, out)
print("Downloaded:", out)
PY
    return 0
  fi

  echo "ERROR: No downloader available (curl/wget/busybox/python3)." >&2
  exit 1
}

# OSRM 파일 존재 여부 체크: 보통 .osrm 파일이 있으면 전처리 완료로 봄
if [ ! -f "${OSRM_BASENAME}" ]; then
  echo "No OSRM data found. Start preprocessing..."

  if [ ! -f "${PBF_PATH}" ]; then
    download_pbf "${PBF_URL}" "${PBF_PATH}"
  else
    echo "PBF already exists: ${PBF_PATH}"
  fi

  echo "Running osrm-extract..."
  osrm-extract -p "${PROFILE}" "${PBF_PATH}"

  echo "Running osrm-partition..."
  osrm-partition "${OSRM_BASENAME}"

  echo "Running osrm-customize..."
  osrm-customize "${OSRM_BASENAME}"

  echo "Preprocessing complete."
else
  echo "OSRM data already exists: ${OSRM_BASENAME}"
fi

echo "Starting osrm-routed..."
exec osrm-routed --algorithm "${ALGO}" "${OSRM_BASENAME}" --max-table-size "${MAX_TABLE_SIZE}"
