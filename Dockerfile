FROM osrm/osrm-backend:latest

WORKDIR /data

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 5000
ENTRYPOINT ["/start.sh"]
