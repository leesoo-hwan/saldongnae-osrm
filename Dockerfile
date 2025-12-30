FROM osrm/osrm-backend:latest

WORKDIR /data

# 기본값(필요하면 fly.toml의 [env]로 override 가능)
ENV REGION_NAME=south-korea
ENV PBF_URL=https://download.geofabrik.de/asia/south-korea-latest.osm.pbf
ENV PROFILE=/opt/car.lua
ENV ALGO=mld

# ✅ 빌드 시점에 PBF를 받아서 이미지에 넣어둠 (curl/wget 필요 없음)
ADD ${PBF_URL} /data/${REGION_NAME}.osm.pbf

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 5000
ENTRYPOINT ["/start.sh"]
