FROM osrm/osrm-backend:latest

RUN apt-get update && apt-get install -y curl ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /data

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 5000

ENTRYPOINT ["/start.sh"]
