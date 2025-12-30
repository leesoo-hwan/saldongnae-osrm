# 1) tools stage: curl + ca-certificates 준비 (apk는 안정적)
FROM alpine:3.20 AS tools
RUN apk add --no-cache curl ca-certificates

# 2) runtime stage: OSRM
FROM osrm/osrm-backend:latest

WORKDIR /data

# curl 실행파일 + 인증서만 복사 (apt-get 필요 없음)
COPY --from=tools /usr/bin/curl /usr/bin/curl
COPY --from=tools /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

# (중요) PBF를 이미지에 ADD 하지 말 것! -> 런타임에 /data 볼륨에 다운로드
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 5000
ENTRYPOINT ["/start.sh"]
