FROM osrm/osrm-backend:latest

WORKDIR /data

# curl 설치 (이게 지금 빠져 있었음)
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

ENV REGION_NAME=south-korea
ENV PBF_URL=https://download.geofabrik.de/asia/south-korea-latest.osm.pbf
ENV PROFILE=/opt/car.lua
ENV ALGO=mld

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 5000
ENTRYPOINT ["/start.sh"]
