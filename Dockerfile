FROM osrm/osrm-backend:latest

WORKDIR /data

ENV REGION_NAME=south-korea
ENV PROFILE=/opt/car.lua
ENV ALGO=mld

# Docker가 URL을 직접 다운로드 (툴 필요 없음)
ADD https://download.geofabrik.de/asia/south-korea-latest.osm.pbf /data/south-korea.osm.pbf

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 5000
ENTRYPOINT ["/start.sh"]
