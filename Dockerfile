# syntax=docker/dockerfile:1

FROM teddysun/xray

RUN apk update
RUN apk add gettext        # envsubst
RUN apk add bash           # bash

COPY ./xray/ /app/xray/
COPY --chmod=755 ./entrypoint.sh /

ENV TZ=""

ENV LOG_LEVEL=info
ENV PROTOCOL=tcp
ENV WEBSOCKET_PATH=/path/
ENV PROXY_ADDRESS=127.0.0.1
ENV PROXY_PORT=80

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/xray", "run", "-confdir", "/etc/xray.d/"]

EXPOSE 80

HEALTHCHECK  --interval=15m \
    --start-interval=30s \
    --start-period=30s \
    CMD nc -z localhost 80 || exit 1
