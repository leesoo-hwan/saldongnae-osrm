FROM osrm/osrm-backend:latest

WORKDIR /data

# Fly.toml에서 쓰는 REGION_NAME/PBF_URL과 맞춰줘야 함
ENV REGION_NAME=south-korea
ENV PBF_URL=https://download.geofabrik.de/asia/south-korea-latest.osm.pbf
ENV PROFILE=/opt/car.lua
ENV ALGO=mld

# Docker 빌드 기능: URL을 그냥 가져올 수 있음 (curl/wget 불필요)
ADD ${PBF_URL} /data/${REGION_NAME}.osm.pbf

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 5000
ENTRYPOINT ["/start.sh"]
