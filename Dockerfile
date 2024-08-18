# syntax=docker/dockerfile:1

FROM teddysun/xray

RUN apk update
RUN apk add gettext        # envsubst
RUN apk add bash           # bash
RUN apk add curl           # curl
RUN apk add jq             # jq
RUN apk add supervisor     # supervisor

COPY ./xray/ /app/xray/
COPY --chmod=755 ./entrypoint.sh /usr/bin/entrypoint.sh
COPY --chmod=755 ./generate-config.sh /usr/bin/generate-config.sh
COPY supervisord.conf /etc/supervisor/supervisord.conf
RUN mkdir /etc/xray.d/
RUN mkdir /output/
ENV TZ=""

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

ENTRYPOINT ["/usr/bin/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

EXPOSE 80
EXPOSE 81

HEALTHCHECK  --interval=15m \
    --start-interval=30s \
    --start-period=30s \
    CMD nc -z localhost 80 && curl -f http://localhost:81/ || exit 1
