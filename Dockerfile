# syntax=docker/dockerfile:1

FROM teddysun/xray:1.8.24 AS xray
FROM alpine:3

RUN apk update && \
    apk add bash curl jq supervisor gettext-envsubst

RUN addgroup --system xray && \
    adduser --system --disabled-password xray xray

COPY --from=xray --chmod=755 /usr/bin/xray /usr/bin/xray
COPY ./xray/ /app/xray/
COPY --chmod=755 ./entrypoint.sh /usr/bin/entrypoint.sh
COPY --chmod=755 ./generate-config.sh /usr/bin/generate-config.sh
COPY supervisord.conf /etc/supervisor/supervisord.conf

RUN install -d -o xray -g xray /etc/xray.d/
RUN install -d -o xray -g xray /output/

ENV LOG_LEVEL=info
ENV PROTOCOL=tcp
ENV WS_PATH=/path
ENV WARP_ADDRESS=127.0.0.1
ENV WARP_PORT=80

ENV GENERATE_DIRECT_CONFIGS=false
ENV GENERATE_TUNNEL_CONFIGS=true
ENV GENERATE_WORKER_CONFIGS=true
ENV GENERATE_IPV4_CONFIGS=false
ENV GENERATE_IPV6_CONFIGS=true
ENV GENERATE_WARP_CONFIGS=true

USER xray

ENTRYPOINT ["/usr/bin/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

EXPOSE 80
EXPOSE 81

HEALTHCHECK  --interval=15m \
    --start-interval=30s \
    --start-period=30s \
    CMD nc -z localhost 80 && curl -f http://localhost:81/ || exit 1
