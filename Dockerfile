# syntax=docker/dockerfile:1

FROM teddysun/xray

RUN apk update
RUN apk add gettext        # for: envsubst
RUN apk add moreutils      # for: sponge

COPY ./conf/ /etc/xray.d/
COPY --chmod=755 ./entrypoint.sh /

ENV TZ=""

ENV LOG_LEVEL="info"
ENV PROTOCOL="tcp"

ENV USER_ID_DIRECT="facade00-0000-4000-a000-000000000000"
ENV USER_ID_PROXY="decade00-0000-4000-a000-000000000000"

ENV WEBSOCKET_PATH="/path/"

ENV REALITY_PRIVATE_KEY="aAmertGRfeZ_qed965PIrhvxIC46Q3GS6jngqC-qhDE"
ENV REALITY_PUBLIC_KEY="awZVJXYAHw_fqfYxwSTgcExrwKPknU5KO9z-CCPGjhs"
ENV REALITY_SNI="example.com"

ENV PROXY_ADDRESS="127.0.0.1"
ENV PROXY_PORT="80"

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/xray", "run", "-confdir", "/etc/xray.d/"]

EXPOSE 80

HEALTHCHECK  --interval=15m \
    --start-interval=30s \
    --start-period=30s \
    CMD nc -z localhost 80 || exit 1
